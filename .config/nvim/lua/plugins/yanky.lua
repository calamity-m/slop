local yanky = require("yanky")

yanky.setup({
	ring = {
		permanent_wrapper = require("yanky.wrappers").remove_carriage_return,
	},
})

local map = vim.keymap.set

map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
map("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
map("n", "<c-n>", "<Plug>(YankyNextEntry)")

map("n", "<leader>fy", "<cmd>YankyRingHistory<cr>", { desc = "Yank History" })
