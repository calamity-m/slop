-- Switch between DAP UI plugins by changing this value: "view" or "ui"
local use = "view"

local map = vim.keymap.set

if use == "view" then
	local dap_view = require("dap-view")
	dap_view.setup({ auto_toggle = true })

	map("n", "<leader>dvt", "<cmd>DapViewToggle!<CR>", { desc = "DAP View Toggle" })
	map("n", "<leader>dvh", "<cmd>DapViewHover<CR>", { desc = "DAP View Hover" })
	map("v", "<leader>dvh", "<cmd>DapViewHover<CR>", { desc = "DAP View Hover Selection" })
elseif use == "ui" then
	local dap = require("dap")
	local dapui = require("dapui")
	dapui.setup()

	dap.listeners.after.event_initialized["dapui_config"] = dapui.open
	dap.listeners.before.event_terminated["dapui_config"] = dapui.close
	dap.listeners.before.event_exited["dapui_config"] = dapui.close

	map("n", "<leader>dvt", dapui.toggle, { desc = "DAP UI Toggle" })
	map("n", "<leader>dvh", dapui.eval, { desc = "DAP UI Eval" })
	map("v", "<leader>dvh", dapui.eval, { desc = "DAP UI Eval Selection" })
end
