require("markview").setup({
	preview = {
		icon_provider = "devicons",
	},
})

-- Dim the --- frontmatter delimiters (captured as @keyword.directive in markdown)
vim.api.nvim_set_hl(0, "@keyword.directive.markdown", { link = "Comment" })
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "@keyword.directive.markdown", { link = "Comment" })
	end,
})
