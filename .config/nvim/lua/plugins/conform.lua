local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" }, -- Lua formatter
		go = { "goimports", "gofmt" }, -- imports first, then format
		python = { "ruff" }, -- fast Python formatter/linter
		rust = { "rustfmt" }, -- Rust formatter

		-- JS/TS ecosystem via oxfmt (fast, Rust-based)
		javascript = { "oxfmt" },
		javascriptreact = { "oxfmt" },
		typescript = { "oxfmt" },
		typescriptreact = { "oxfmt" },
		json = { "oxfmt" },
		jsonc = { "oxfmt" }, -- JSON with comments (tsconfig, etc.)
		mjs = { "oxfmt" }, -- ES modules
		cjs = { "oxfmt" }, -- CommonJS modules
		vue = { "oxfmt" }, -- mainly script blocks
		toml = { "tombi" }, -- proper TOML formatter
		kdl = { "kdlfmt" }, -- KDL formatter
	},

	formatters = {
		kdlfmt = {
			-- skip config.kdl formatting for zellij
			condition = function(_, ctx)
				return not ctx.filename:match("config%.kdl$")
			end,
		},
	},

	default_format_opts = {
		lsp_format = "fallback", -- use LSP if no external formatter
	},

	format_on_save = {
		lsp_format = "fallback", -- try external first, fallback to LSP
		timeout_ms = 500, -- prevent long blocking on save
	},
})
