require("neogit").setup({
	integrations = {
		diffview = true,
	},
})

local map = vim.keymap.set

map("n", "<leader>Gg", "<cmd>Neogit<cr>", { desc = "Git Neogit" })
