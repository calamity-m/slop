local M = {}

function M.setup()
	local jdtls = require("jdtls")
	local mason_path = vim.fn.stdpath("data") .. "/mason"
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
		local formatter_profile = "calam-jdtls"
		local formatter_path = vim.fn.stdpath("cache") .. "/jdtls-formatter.xml"
		local line_length = tonumber(opts.format_line_length) or 120
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

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		callback = function()
			jdtls.start_or_attach({
				-- Use Mason's jdtls directly so Java LSP does not depend on shell PATH setup.
				cmd = { mason_path .. "/bin/jdtls" },
				root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts", ".git" }),
				settings = settings,
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

M.setup()

return M
