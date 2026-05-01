local dap = require("dap")
local dap_view = require("dap-view")
local mason_nvim_dap = require("mason-nvim-dap")
local map = vim.keymap.set

dap_view.setup({
	auto_toggle = true,
})

mason_nvim_dap.setup({
	ensure_installed = {
		"codelldb",
		"delve",
		"python",
		"js-debug-adapter",
	},
	handlers = {},
})

require("plugins.dap.rust").setup(dap)
require("plugins.dap.python").setup()
require("plugins.dap.go").setup()
require("plugins.dap.javascript").setup()

vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DapLogPoint", { text = "L", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticSignHint" })
vim.fn.sign_define("DapBreakpointRejected", { text = "R", texthl = "DiagnosticSignError" })

map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP Conditional Breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "DAP Continue" })
map("n", "<leader>dC", dap.run_to_cursor, { desc = "DAP Run To Cursor" })
map("n", "<leader>di", dap.step_into, { desc = "DAP Step Into" })
map("n", "<leader>do", dap.step_over, { desc = "DAP Step Over" })
map("n", "<leader>dO", dap.step_out, { desc = "DAP Step Out" })
map("n", "<leader>dr", dap.repl.open, { desc = "DAP REPL" })
map("n", "<leader>dl", dap.run_last, { desc = "DAP Run Last" })
map("n", "<leader>dq", dap.terminate, { desc = "DAP Terminate" })
map("n", "<leader>dv", "<cmd>DapViewToggle<CR>", { desc = "DAP View Toggle" })
