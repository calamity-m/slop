local M = {}

function M.setup()
	local dap_go = require("dap-go")

	dap_go.setup()

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "go",
		callback = function(event)
			vim.keymap.set("n", "<leader>dt", dap_go.debug_test, {
				buffer = event.buf,
				desc = "DAP Test",
			})

			vim.keymap.set("n", "<leader>dT", dap_go.debug_last_test, {
				buffer = event.buf,
				desc = "DAP Last Test",
			})
		end,
	})
end

return M
