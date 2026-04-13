vim.pack.add({
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

require("custom.theme_picker").load_saved()
