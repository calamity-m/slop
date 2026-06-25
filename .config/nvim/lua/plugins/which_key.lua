local wk = require("which-key")

wk.setup({
	preset = "helix",
	delay = 300,
	icons = {
		mappings = false,
	},
})

wk.add({
	{ "<leader>a", group = "Atlas" },
	{ "<leader>aa", group = "Atlas GitHub" },
	{ "<leader>ag", group = "Atlas GitLab" },
	{ "<leader>b", group = "Buffer" },
	{ "<leader>c", group = "Code" },
	{ "<leader>d", group = "DAP" },
	{ "<leader>f", group = "Find" },
	{ "<leader>fe", group = "Explorer" },
	{ "<leader>h", group = "Haunt" },
	{ "<leader>g", group = "Goto / LSP" },
	{ "<leader>G", group = "Git" },
	{ "<leader>Gt", group = "Git Toggles" },
	{ "<leader>Gv", group = "Git Diffview" },
	{ "<leader>M", group = "Mason" },
	{ "<leader>v", group = "Vim" },
	{ "<leader>vp", group = "Pack" },
	{ "<leader>vs", group = "Session" },
})
