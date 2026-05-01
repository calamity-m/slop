local M = {}

-- nvim-dap ultimately needs an executable path to launch. Cargo projects usually
-- start from a manifest and produce the executable as build output, so this file
-- runs Cargo first, reads its JSON output, then hands the chosen artifact to
-- codelldb.

local function cargo_root()
	return vim.fs.root(0, { "Cargo.toml" })
end

local function target_has_kind(target, kind)
	if not target then
		return false
	end

	return vim.tbl_contains(target.kind or {}, kind)
end

local function input_args(prompt)
	return vim.split(vim.fn.input(prompt), "%s+", { trimempty = true })
end

-- Cargo can produce multiple executables for a single command, for example a
-- workspace with several bins or test harnesses. Pick automatically only when
-- there is no ambiguity.
local function select_executable(executables, title)
	if #executables == 0 then
		error("No Cargo executable artifact found")
	end

	if #executables == 1 then
		return executables[1].path
	end

	local choices = { title }

	for index, executable in ipairs(executables) do
		table.insert(choices, string.format("%d. %s", index, executable.label))
	end

	local choice = vim.fn.inputlist(choices)

	if choice < 1 or choice > #executables then
		error("No Cargo executable selected")
	end

	return executables[choice].path
end

-- Run a Cargo command, parse its `compiler-artifact` messages, and return one
-- executable path. This is the bridge between "cargo build/test" and
-- "debug this exact binary".
local function cargo_artifact(cargo_args, artifact_filter, title)
	local root = cargo_root()

	if not root then
		error("No Cargo.toml found")
	end

	local command = vim.list_extend({ "cargo" }, vim.deepcopy(cargo_args))
	table.insert(command, "--message-format=json")

	local result = vim.system(command, { cwd = root, text = true }):wait()

	if result.code ~= 0 then
		error(result.stderr)
	end

	local executables = {}

	for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
		local ok, message = pcall(vim.json.decode, line)

		-- Only compiler artifacts with an executable are useful to codelldb.
		if ok and message.reason == "compiler-artifact" and message.executable and artifact_filter(message) then
			table.insert(executables, {
				path = message.executable,
				label = string.format("%s [%s]", message.target.name, table.concat(message.target.kind or {}, ",")),
			})
		end
	end

	return select_executable(executables, title)
end

-- Normal CLI/app debugging: build bins and launch the selected binary.
local function build_cargo_binary()
	return cargo_artifact({ "build" }, function(message)
		return target_has_kind(message.target, "bin")
	end, "Select Cargo binary:")
end

-- Test harness arguments are passed to the compiled test executable, not to
-- Cargo. Blank means "run the whole selected harness".
local function test_args()
	local args = input_args("Test filter: ")
	table.insert(args, "--nocapture")

	return args
end

-- Cargo can target top-level integration tests, examples, and src/bin files by
-- name. Regular module files under src/ belong to the lib test harness, so there
-- is no real "just this file" Cargo target for those.
local function current_file_test_cargo_args()
	local root = cargo_root()

	if not root then
		error("No Cargo.toml found")
	end

	local path = vim.api.nvim_buf_get_name(0)
	local relative = vim.fs.relpath(root, path)

	if not relative then
		return { "test", "--no-run" }
	end

	local integration_test = relative:match("^tests/(.+)%.rs$")
	if integration_test and not integration_test:find("/") then
		return { "test", "--test", integration_test, "--no-run" }
	end

	local example = relative:match("^examples/(.+)%.rs$")
	if example and not example:find("/") then
		return { "test", "--example", example, "--no-run" }
	end

	local bin = relative:match("^src/bin/(.+)%.rs$")
	if bin and not bin:find("/") then
		return { "test", "--bin", bin, "--no-run" }
	end

	if relative == "src/main.rs" then
		return { "test", "--no-run" }
	end

	if relative == "src/lib.rs" or relative:match("^src/") then
		return { "test", "--lib", "--no-run" }
	end

	return { "test", "--no-run" }
end

-- Build the test harness that best matches the open buffer, then debug it.
local function build_current_file_tests()
	return cargo_artifact(current_file_test_cargo_args(), function(message)
		return message.profile and message.profile.test
	end, "Select Cargo test executable:")
end

-- Build every test harness Cargo knows about, then let the user choose.
local function build_all_tests()
	return cargo_artifact({ "test", "--no-run" }, function(message)
		return message.profile and message.profile.test
	end, "Select Cargo test executable:")
end

function M.setup(dap)
	dap.configurations.rust = {
		{
			-- Build and debug a Cargo binary target.
			name = "Cargo debug binary",
			type = "codelldb",
			request = "launch",
			program = build_cargo_binary,
			cwd = cargo_root,
			args = function()
				return input_args("Args: ")
			end,
			stopOnEntry = false,
		},
		{
			-- Debug tests for the current file where possible; otherwise use the
			-- nearest sensible test harness.
			name = "Cargo debug current file tests",
			type = "codelldb",
			request = "launch",
			program = build_current_file_tests,
			cwd = cargo_root,
			args = test_args,
			stopOnEntry = false,
		},
		{
			-- Useful when you want to choose from every test harness in the crate
			-- or workspace.
			name = "Cargo debug all tests",
			type = "codelldb",
			request = "launch",
			program = build_all_tests,
			cwd = cargo_root,
			args = test_args,
			stopOnEntry = false,
		},
		{
			-- Escape hatch for unusual builds, custom cargo commands, or binaries
			-- produced outside the normal target/debug layout.
			name = "Cargo debug executable artifact",
			type = "codelldb",
			request = "launch",
			program = function()
				local root = cargo_root() or vim.fn.getcwd()
				return vim.fn.input("Executable: ", root .. "/target/debug/", "file")
			end,
			cwd = cargo_root,
			args = function()
				return input_args("Args: ")
			end,
			stopOnEntry = false,
		},
	}
end

return M
