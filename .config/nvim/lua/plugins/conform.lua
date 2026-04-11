local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = {
			"goimports",
			"gofmt",
			stop_after_first = true,
		},
		python = { "ruff" },
		rust = { "rustfmt" },
		javascript = { "oxfmt" },
		javascriptreact = { "oxfmt" },
		typescript = { "oxfmt" },
		typescriptreact = { "oxfmt" },
		json = { "oxfmt" },
		vue = { "oxfmt" },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
	format_after_save = {
		lsp_format = "fallback",
	},
})

local conform_group = vim.api.nvim_create_augroup("ConformFormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = conform_group,
	pattern = "*",
	callback = function(args)
		conform.format({ bufnr = args.buf })
	end,
})
