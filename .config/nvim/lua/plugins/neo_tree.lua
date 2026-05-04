require("neo-tree").setup({
	close_if_last_window = true,
	window = {
		position = "float",
		width = 36,
		mappings = {
			["<space>"] = "none",
		},
	},
	popup_border_style = "rounded",
	filesystem = {
		use_libuv_file_watcher = true,
		follow_current_file = {
			enabled = true,
			leave_dirs_open = false,
		},
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
			never_show = { ".git" },
		},
	},
})

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle filesystem reveal<CR>", {
	desc = "Explorer Toggle",
})
