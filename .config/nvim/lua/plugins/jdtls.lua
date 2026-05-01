local M = {}

function M.setup()
	local jdtls = require("jdtls")
	local mason_path = vim.fn.stdpath("data") .. "/mason"

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

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		callback = function()
			jdtls.start_or_attach({
				cmd = { mason_path .. "/bin/jdtls" },
				root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts", ".git" }),
				settings = { java = {} },
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
				end,
			})
		end,
	})
end

return M
