require("illuminate").configure({
	providers = { "regex" },
	delay = 100,
	under_cursor = true,
	min_count_to_highlight = 2,
})

local function set_illuminate_highlights()
	local highlight = { underline = true }

	vim.api.nvim_set_hl(0, "IlluminatedWordText", highlight)
	vim.api.nvim_set_hl(0, "IlluminatedWordRead", highlight)
	vim.api.nvim_set_hl(0, "IlluminatedWordWrite", highlight)
end

set_illuminate_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("IlluminateHighlights", { clear = true }),
	callback = set_illuminate_highlights,
})
