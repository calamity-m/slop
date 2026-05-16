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
		[".gitlab-ci.yml"] = "yaml.gitlab",
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["compose.yaml"] = "yaml.docker-compose",
	},
	extension = {
		gotmpl = "gotmpl",
		tmpl = "gotmpl",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function()
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
		vim.bo.expandtab = true
	end,
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.lsp.start({
			name = "peanutbutter",
			cmd = { "peanutbutter", "lsp" },
			-- root_dir tells Neovim which directory to treat as the project root.
			-- Here we walk up looking for a marker file, mirroring the server's own logic.
			root_dir = (function()
				local markers = { ".peanutbutter.toml", "peanutbutter.toml", "_peanutbutter.toml" }
				return vim.fs.dirname(vim.fs.find(markers, { upward = true })[1])
			end)(),
		})
	end,
})
