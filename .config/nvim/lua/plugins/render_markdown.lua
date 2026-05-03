require("render-markdown").setup({
	completions = {
		lsp = { enabled = true },
	},
	heading = {
		icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
	},
	code = {
		left_pad = 2,
		right_pad = 2,
		language_name = false,
		language_icon = false,
	},
})

local render_markdown_group = vim.api.nvim_create_augroup("RenderMarkdownKeymaps", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = render_markdown_group,
	pattern = "markdown",
	callback = function(event)
		vim.keymap.set("n", "<leader>tM", require("render-markdown").buf_toggle, {
			buffer = event.buf,
			desc = "Toggle Markdown Render",
		})
	end,
})
