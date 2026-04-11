vim.pack.add({
	{ src = "https://github.com/zaldih/themery.nvim" },
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/webhooked/kanso.nvim" },
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	{ src = "https://github.com/sainnhe/gruvbox-material" },
	{ src = "https://github.com/savq/melange-nvim" },
	{ src = "https://github.com/oskarnurm/koda.nvim" },
	{ src = "https://github.com/nikolvs/vim-sunbather" },
}, { confirm = false })

require("kanagawa").setup({
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none",
				},
			},
		},
	},
})

local themery = require("themery")

themery.setup({
	themes = {
		{ name = "Kanagawa Dragon", colorscheme = "kanagawa-dragon" },
		{ name = "Kanagawa Wave", colorscheme = "kanagawa-wave" },

		{ name = "Rose Pine Moon", colorscheme = "rose-pine-moon" },

		{
			name = "Gruvbox Material (Soft)",
			colorscheme = "gruvbox-material",
			before = [[
				vim.g.gruvbox_material_background = "soft"
				vim.g.gruvbox_material_better_performance = true
      ]],
		},
		{
			name = "Gruvbox Material (Medium)",
			colorscheme = "gruvbox-material",
			before = [[
        vim.g.gruvbox_material_background = "medium"
        vim.g.gruvbox_material_better_performance = true
      ]],
		},
		{
			name = "Gruvbox Material (Hard)",
			colorscheme = "gruvbox-material",
			before = [[
        vim.g.gruvbox_material_background = "hard"
        vim.g.gruvbox_material_better_performance = true
      ]],
		},
		{ name = "Melange", colorscheme = "melange" },
		{ name = "Kanso Zen", colorscheme = "kanso-zen" },
		{ name = "Kanso Ink", colorscheme = "kanso-ink" },
		{ name = "Kanso Mist", colorscheme = "kanso-mist" },
		{ name = "Koda", colorscheme = "koda" },
		{ name = "Sunbather", colorscheme = "sunbather" },
	},
	livePreview = true,
})
