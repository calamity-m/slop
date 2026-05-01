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

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function(event)
			vim.keymap.set("n", "<leader>dt", dap_python.test_method, {
				buffer = event.buf,
				desc = "DAP Test",
			})

			vim.keymap.set("n", "<leader>dT", dap_python.test_class, {
				buffer = event.buf,
				desc = "DAP Test Class",
			})
		end,
	})
end

return M
