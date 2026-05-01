local fzf = require("fzf-lua")

fzf.setup({
	"fzf-native",
	winopts = {
		height = 0.85,
		width = 0.80,
		row = 0.35,
		col = 0.50,
		border = "rounded",
		preview = {
			layout = "flex",
			flip_columns = 120,
			scrollbar = "float",
		},
	},
	keymap = {
		fzf = {
			["ctrl-q"] = "select-all+accept",
		},
	},
	grep = {
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/' --max-columns=4096 -e",
	},
})

fzf.register_ui_select()

local map = vim.keymap.set

map("n", "F", fzf.global, { desc = "Fzf Global" })
map("n", "<leader>ff", fzf.global, { desc = "Fzf Global" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Live Grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })

map("n", "<leader>cD", fzf.diagnostics_document, { desc = "Document Diagnostics" })
map("n", "<leader>cs", fzf.lsp_document_symbols, { desc = "Document Symbols" })

map("n", "gri", fzf.lsp_implementations, { desc = "Goto Implementation" })
map("n", "grr", fzf.lsp_references, { desc = "Goto References" })
map("n", "grt", fzf.lsp_typedefs, { desc = "Goto Type Definition" })
map("n", "gO", fzf.lsp_document_symbols, { desc = "Document Symbols" })

map("n", "<leader>gr", fzf.lsp_references, { desc = "References" })
map("n", "<leader>gi", fzf.lsp_implementations, { desc = "Implementations" })
map("n", "<leader>gt", fzf.lsp_typedefs, { desc = "Type Definitions" })
