local M = {}

function M.setup()
	local jdtls = require("jdtls")
	local mason_path = vim.fn.stdpath("data") .. "/mason"
	local lombok_path = mason_path .. "/packages/jdtls/lombok.jar"
	local opts = {
		format_line_length = 120,
		settings = {},
	}

	pcall(function()
		opts = vim.tbl_deep_extend("force", opts, require("local.jdtls"))
	end)

	-- Collect debug adapter JARs installed by Mason
	local bundles = vim.split(
		vim.fn.glob(
			mason_path .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
		),
		"\n",
		{ trimempty = true }
	)
	vim.list_extend(bundles, vim.split(
		vim.fn.glob(mason_path .. "/packages/java-test/extension/server/*.jar"),
		"\n",
		{ trimempty = true }
	))

	local function build_settings(root_dir)
		local settings = vim.tbl_deep_extend("force", {
			java = {
				format = { enabled = true },
			},
		}, opts.settings or {})

		local has_formatter_settings_url = settings.java
			and settings.java.format
			and settings.java.format.settings
			and settings.java.format.settings.url

		if not has_formatter_settings_url then
			local project_formatter_path
			if root_dir then
				for _, formatter_name in ipairs({ "eclipse.xml", "eclipse-formatter.xml" }) do
					local candidate = root_dir .. "/" .. formatter_name
					if vim.fn.filereadable(candidate) == 1 then
						project_formatter_path = candidate
						break
					end
				end
			end

			if project_formatter_path then
				settings.java.format.settings = {
					url = project_formatter_path,
					profile = "eclipse",
				}
			else
				local formatter_profile = "eclipse"
				local formatter_path = vim.fn.stdpath("cache") .. "/jdtls-formatter.xml"
				local line_length = 120
				-- jdtls only exposes formatter width through an Eclipse formatter profile.
				vim.fn.writefile({
					'<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
					'<profiles version="13">',
					string.format('\t<profile kind="CodeFormatterProfile" name="%s" version="13">', formatter_profile),
					string.format(
						'\t\t<setting id="org.eclipse.jdt.core.formatter.lineSplit" value="%d"/>',
						line_length
					),
					"\t</profile>",
					"</profiles>",
				}, formatter_path)
				settings.java.format.settings = {
					url = formatter_path,
					profile = formatter_profile,
				}
			end
		end

		return settings
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		callback = function()
			local root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
			local workspace_dir = vim.fn.stdpath("data")
				.. "/jdtls-workspace/"
				.. vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ":t")
			local cmd = { mason_path .. "/bin/jdtls", "-data", workspace_dir }
			if vim.fn.filereadable(lombok_path) == 1 then
				-- JDTLS needs Lombok as a JVM agent to see generated methods and constructors.
				table.insert(cmd, 2, "--jvm-arg=-javaagent:" .. lombok_path)
			end

			jdtls.start_or_attach({
				-- Use Mason's jdtls directly so Java LSP does not depend on shell PATH setup.
				cmd = cmd,
				root_dir = root_dir,
				settings = build_settings(root_dir),
				init_options = { bundles = bundles },
				on_attach = function(_, bufnr)
					-- setup_dap must run after the server attaches so jdtls can register DAP handlers
					jdtls.setup_dap({ hotcodereplace = "auto" })
					vim.keymap.set("n", "<leader>ci", jdtls.organize_imports, {
						buffer = bufnr,
						desc = "Organize Imports",
					})
					vim.keymap.set("n", "<leader>cev", jdtls.extract_variable, {
						buffer = bufnr,
						desc = "Extract Variable",
					})
					vim.keymap.set("v", "<leader>cev", function()
						jdtls.extract_variable(true)
					end, {
						buffer = bufnr,
						desc = "Extract Variable",
					})
					vim.keymap.set("n", "<leader>cec", jdtls.extract_constant, {
						buffer = bufnr,
						desc = "Extract Constant",
					})
					vim.keymap.set("v", "<leader>cec", function()
						jdtls.extract_constant(true)
					end, {
						buffer = bufnr,
						desc = "Extract Constant",
					})
					vim.keymap.set("v", "<leader>cem", function()
						jdtls.extract_method(true)
					end, {
						buffer = bufnr,
						desc = "Extract Method",
					})
					vim.keymap.set("n", "<leader>dt", jdtls.test_nearest_method, {
						buffer = bufnr,
						desc = "DAP Test Nearest Method",
					})
					vim.keymap.set("n", "<leader>dT", jdtls.test_class, {
						buffer = bufnr,
						desc = "DAP Test Class",
					})
					vim.keymap.set("n", "<leader>cju", jdtls.update_projects_config, {
						buffer = bufnr,
						desc = "Update Java Project Config",
					})
					vim.keymap.set("n", "<leader>cjb", function()
						jdtls.compile(true)
					end, {
						buffer = bufnr,
						desc = "Build Java Project",
					})
				end,
			})
		end,
	})
end

M.setup()

return M
