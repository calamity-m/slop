require("neo-tree").setup({
	sources = {
		"filesystem",
		"buffers",
		"git_status",
		"diagnostics",
	},
	close_if_last_window = true,
	window = {
		position = "float",
		width = 36,
		mappings = {
			["<space>"] = "none",
			-- copy name/path as text to the system clipboard; leaves the
			-- default `y`/`x`/`p` file-operation clipboard untouched
			["Y"] = "copy_path_to_clipboard",
			["gy"] = "copy_filename_to_clipboard",
		},
	},
	commands = {
		copy_filename_to_clipboard = function(state)
			local node = state.tree:get_node()
			vim.fn.setreg("+", node.name)
			vim.notify("Copied: " .. node.name)
		end,
		copy_path_to_clipboard = function(state)
			local node = state.tree:get_node()
			vim.fn.setreg("+", node.path)
			vim.notify("Copied: " .. node.path)
		end,
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

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle filesystem<CR>", {
	desc = "Explorer Toggle",
})

vim.keymap.set("n", "<leader>fed", "<cmd>Neotree diagnostics reveal float<CR>", {
	desc = "Explorer Diagnostics",
})

vim.keymap.set("n", "<leader>feg", "<cmd>Neotree git_status reveal float<CR>", {
	desc = "Explorer Git Status",
})
