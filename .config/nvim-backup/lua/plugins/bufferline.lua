local map = vim.keymap.set
local bufferline = require("bufferline")

bufferline.setup({
	options = {
		mode = "buffers",
		always_show_bufferline = true,
		diagnostics = "nvim_lsp",
		separator_style = "slant",
		show_close_icon = false,
		show_buffer_close_icons = true,
		offsets = {
			{
				filetype = "neo-tree",
				text = "Explorer",
				text_align = "left",
				separator = true,
			},
		},
	},
})

map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete Other Buffers" })
