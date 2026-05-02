local map = vim.keymap.set
local mason = require("plugins.mason")

vim.lsp.enable(mason.lsp_servers)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end,
})

map("n", "<leader>gg", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>gh", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "<leader>th", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

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

vim.lsp.config("gopls", {
	settings = {
		gopls = {
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
})

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			inlayHints = {
				typeHints = {
					enable = true,
				},
				parameterHints = {
					enable = true,
				},
				chainingHints = {
					enable = true,
				},
			},
		},
	},
})

vim.lsp.config("ty", {
	settings = {
		ty = {
			inlayHints = {
				variableTypes = true,
				callArgumentNames = true,
			},
		},
	},
})
