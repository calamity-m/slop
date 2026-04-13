local map = vim.keymap.set
local neo_tree = require("neo-tree")

neo_tree.setup({
	window = {
		width = 30,
		mappings = {
			["<space>"] = "none",
		},
	},
	filesystem = {
		use_libuv_file_watcher = true,
		follow_current_file = {
			enabled = true,
			leave_dirs_open = false,
		},
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
		},
	},
	git_status = {
		symbols = {
			added = "",
			modified = "",
			deleted = "✖",
			renamed = "󰁕",
			untracked = "",
			ignored = "",
			unstaged = "󰄱",
			staged = "",
			conflict = "",
		},
	},
})

map("n", "<leader>e", "<cmd>Neotree toggle filesystem reveal left<CR>", { desc = "Explorer Toggle" })
map("n", "<leader>o", "<cmd>Neotree focus filesystem left<CR>", { desc = "Explorer Focus" })
map("n", "<leader>be", "<cmd>Neotree show buffers right<CR>", { desc = "Buffer Explorer" })
map("n", "<leader>er", "<cmd>Neotree reveal filesystem left<CR>", { desc = "Explorer Reveal Current File" })
