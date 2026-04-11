vim.pack.add({
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/webhooked/kanso.nvim" },
}, { confirm = false })

local theme_group = vim.api.nvim_create_augroup("ThemeHighlights", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	group = theme_group,
	callback = function()
		vim.api.nvim_set_hl(0, "BlinkIndent", { fg = "#191922" })
		vim.api.nvim_set_hl(0, "BlinkIndentRed", { fg = "#C34043" })
		vim.api.nvim_set_hl(0, "BlinkIndentYellow", { fg = "#C0A36E" })
		vim.api.nvim_set_hl(0, "BlinkIndentBlue", { fg = "#7E9CD8" })
		vim.api.nvim_set_hl(0, "BlinkIndentTeal", { fg = "#6A9589" })
		vim.api.nvim_set_hl(0, "BlinkIndentViolet", { fg = "#957FB8" })
		vim.api.nvim_set_hl(0, "BlinkIndentOrange", { fg = "#FFA066" })
	end,
})

require("kanagawa").load("dragon")
