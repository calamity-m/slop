local wk = require("which-key")

wk.setup({
	preset = "helix",
	delay = 300,
	icons = {
		mappings = false,
	},
})

wk.add({
	{ "<leader>b", group = "Buffer" },
	{ "<leader>c", group = "Code" },
	{ "<leader>d", group = "DAP" },
	{ "<leader>f", group = "Find" },
	{ "<leader>h", group = "Haunt" },
	{ "<leader>g", group = "Goto / LSP" },
	{ "<leader>G", group = "Git" },
	{ "<leader>Gt", group = "Git Toggles" },
	{ "<leader>M", group = "Mason" },
})
