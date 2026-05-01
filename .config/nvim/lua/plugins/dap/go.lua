local M = {}

function M.setup()
	local dap_go = require("dap-go")

	dap_go.setup()

	vim.keymap.set("n", "<leader>dgt", dap_go.debug_test, { desc = "DAP Go Test" })
	vim.keymap.set("n", "<leader>dgT", dap_go.debug_last_test, { desc = "DAP Go Last Test" })
end

return M
