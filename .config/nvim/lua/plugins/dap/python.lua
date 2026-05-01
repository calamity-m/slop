local M = {}

local function debugpy_adapter()
	local mason_adapter = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/debugpy-adapter"

	if vim.fn.executable(mason_adapter) == 1 then
		return mason_adapter
	end

	return "debugpy-adapter"
end

function M.setup()
	local dap_python = require("dap-python")

	dap_python.setup(debugpy_adapter())

	vim.keymap.set("n", "<leader>dpt", dap_python.test_method, { desc = "DAP Python Test Method" })
	vim.keymap.set("n", "<leader>dpT", dap_python.test_class, { desc = "DAP Python Test Class" })
	vim.keymap.set("x", "<leader>dps", function()
		dap_python.debug_selection()
	end, { desc = "DAP Python Debug Selection" })
end

return M
