local wk = require("which-key")

wk.setup({})

wk.add({
	{ "<leader>b", group = "Buffers" },
	{ "<leader>c", group = "Code / Change" },
	{ "<leader>d", group = "Diagnostics" },
	{ "<leader>e", group = "Explorer" },
	{ "<leader>f", group = "Fzf" },
	{ "<leader>g", group = "Goto / LSP" },
	{ "<leader>m", group = "Multicursor" },
	{ "<leader>G", group = "Git" },
	{ "<leader>Gt", group = "Git Toggles" },
	{ "<leader>s", group = "Symbols" },
	{ "<leader>t", group = "Toggle" },
})
