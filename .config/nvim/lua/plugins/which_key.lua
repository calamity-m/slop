local wk = require("which-key")

wk.setup({
	preset = "helix",
	delay = 300,
	icons = {
		mappings = false,
	},
})

wk.add({
	{ "<leader>f", group = "Find" },
	{ "<leader>h", group = "Haunt" },
	{ "<leader>g", group = "Goto / LSP" },
	{ "<leader>G", group = "Git" },
	{ "<leader>Gt", group = "Git Toggles" },
})
