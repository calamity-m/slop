local map = vim.keymap.set

vim.lsp.enable({
	"rust_analyzer",
	"gopls",
	"lua_ls",
	"ty",
	"oxfmt",
})

map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Goto References" })
map("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "<leader>cs", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("n", "<leader>gg", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>gh", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "<leader>ss", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
map("n", "<leader>sS", function()
	vim.lsp.buf.workspace_symbol("")
end, { desc = "Workspace Symbols" })
