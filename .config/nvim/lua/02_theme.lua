vim.pack.add({
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/sainnhe/gruvbox-material" },
	{ src = "https://github.com/ember-theme/nvim", name = "ember" },
	{ src = "https://github.com/thesimonho/kanagawa-paper.nvim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
}, { confirm = false })

require("kanagawa").setup({
	minimal = false,
	foreground = {
		dark = "saturated",
	},
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none",
				},
			},
			dragon = {
				ui = {
					bg = "#1e1c1a",
					bg_dim = "#1a1818",
					bg_gutter = "none",
				},
			},
		},
	},
})

require("catppuccin").setup({
	flavour = "frappe",
	color_overrides = {
		frappe = {
			base = "#22262D", -- main background (kanso-mist exact)
			mantle = "#1e2228", -- slightly darker (sidebars, statusline)
			crust = "#1a1e24", -- darkest (borders, bottom layer)
		},
	},
})

require("custom.theme_picker").load_saved()
