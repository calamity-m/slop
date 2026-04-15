local treesitter_manager = require("tree-sitter-manager")

treesitter_manager.setup({
	ensure_installed = {
		"bash",
		"lua",
		"python",
		"rust",
		"javascript",
		"zig",
		"go",
		"markdown",
		"json",
		"toml",
		"typescript",
		"tsx",
		"gotmpl",
		"helm",
		"yaml",
	},
})

local treesitter_group = vim.api.nvim_create_augroup("TreesitterAutostart", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = treesitter_group,
	pattern = "*",
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
