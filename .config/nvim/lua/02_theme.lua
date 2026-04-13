vim.pack.add({
	{ src = "https://github.com/zaldih/themery.nvim" },
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/webhooked/kanso.nvim" },
	{ src = "https://github.com/sainnhe/gruvbox-material" },
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

require("kanso").setup({
	overrides = function(colors)
		return {
			DiagnosticUnderlineError = {
				fg = colors.theme.diag.error,
				undercurl = true,
				sp = colors.theme.diag.error,
			},
			DiagnosticUnderlineWarn = {
				fg = colors.theme.diag.warning,
				undercurl = true,
				sp = colors.theme.diag.warning,
			},
			DiagnosticUnderlineInfo = {
				fg = colors.theme.diag.info,
				undercurl = true,
				sp = colors.theme.diag.info,
			},
			DiagnosticUnderlineHint = {
				fg = colors.theme.diag.hint,
				undercurl = true,
				sp = colors.theme.diag.hint,
			},
		}
	end,
})

local themery = require("themery")

themery.setup({
	themes = {
		{ name = "Kanagawa Dragon", colorscheme = "kanagawa-dragon" },
		{ name = "Kanagawa Wave", colorscheme = "kanagawa-wave" },
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
		{ name = "Kanso Ink", colorscheme = "kanso-ink" },
		{ name = "Kanso Mist", colorscheme = "kanso-mist" },
	},
	livePreview = true,
})
