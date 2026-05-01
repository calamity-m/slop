local map = vim.keymap.set

local M = {}

M.lsp_servers = {
	"rust_analyzer",
	"gopls",
	"lua_ls",
	"ty",
	"oxfmt",
	"helm_ls",
	"tombi",
	"marksman",
	"typos_lsp",
}

local tools = {
	"stylua",
	"goimports",
	"ruff",
	"oxfmt",
	"tombi",
	"kdlfmt",
	"xmlformatter",
	"typos",
	"buf",
}

require("mason").setup()

require("mason-lspconfig").setup({
	automatic_enable = false,
})

require("mason-tool-installer").setup({
	ensure_installed = vim.list_extend(vim.deepcopy(M.lsp_servers), tools),
	auto_update = false,
	run_on_start = false,
})

map("n", "<leader>Mm", "<cmd>Mason<CR>", { desc = "Mason UI" })
map("n", "<leader>Mi", "<cmd>MasonToolsInstall<CR>", { desc = "Install Mason Tools" })
map("n", "<leader>Mu", "<cmd>MasonToolsUpdate<CR>", { desc = "Update Mason Tools" })
map("n", "<leader>Mc", "<cmd>MasonToolsClean<CR>", { desc = "Clean Mason Tools" })
map("n", "<leader>Mr", "<cmd>MasonUpdate<CR>", { desc = "Refresh Mason Registry" })
map("n", "<leader>Ml", "<cmd>MasonLog<CR>", { desc = "Mason Log" })
map("n", "<leader>ML", "<cmd>LspInstall<CR>", { desc = "Install LSP For Buffer" })

return M
