vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/TheNoeTrevino/haunt.nvim" },
	{ src = "https://github.com/RRethy/vim-illuminate" },
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/sainnhe/gruvbox-material" },
	{ src = "https://github.com/ember-theme/nvim", name = "ember" },
	{ src = "https://github.com/webhooked/kanso.nvim" },
	{ src = "https://github.com/romus204/tree-sitter-manager.nvim" },
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})

local plugin_modules = {
	"plugins.mini",
	"plugins.which_key",
	"plugins.neo_tree",
	"plugins.fzf",
	"plugins.haunt",
	"plugins.illuminate",
	"plugins.treesitter",
	"plugins.blink",
	"plugins.conform",
	"plugins.lsp",
}

for _, module in ipairs(plugin_modules) do
	require(module)
end
