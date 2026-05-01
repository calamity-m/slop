local M = {}

function M.setup()
	local dap = require("dap")

	-- vscode-js-debug server adapter; Mason installs js-debug-adapter here
	dap.adapters["pwa-chrome"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "node",
			args = {
				vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
				"${port}",
			},
		},
	}

	local configs = {
		{
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome (Vite)",
			url = "http://localhost:5173",
			webRoot = "${workspaceFolder}",
			sourceMaps = true,
		},
		{
			type = "pwa-chrome",
			request = "attach",
			name = "Attach to Chrome",
			port = 9222,
			webRoot = "${workspaceFolder}",
			sourceMaps = true,
		},
	}

	for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
		dap.configurations[ft] = configs
	end
end

return M
