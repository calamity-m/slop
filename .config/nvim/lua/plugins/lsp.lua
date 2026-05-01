local map = vim.keymap.set
local mason = require("plugins.mason")

vim.lsp.enable(mason.lsp_servers)

map("n", "<leader>gg", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>gh", vim.lsp.buf.hover, { desc = "Hover Documentation" })

vim.filetype.add({
	filename = {
		["go.work"] = "gowork",
	},
	extension = {
		gotmpl = "gotmpl",
		tmpl = "gotmpl",
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
