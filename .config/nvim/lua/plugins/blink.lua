local blink_cmp = require("blink.cmp")

local blink_opts = {
	keymap = { preset = "super-tab" },
	appearance = {
		nerd_font_variant = "mono",
		use_nvim_cmp_as_default = true,
	},
	completion = {
		documentation = { auto_show = true },
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		providers = {
			snippets = {
				opts = {
					search_paths = { vim.fn.expand("~/.config/snippets") },
				},
			},
		},
	},
	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
}

pcall(function()
	blink_opts = vim.tbl_deep_extend("force", blink_opts, require("local.blink"))
end)

blink_cmp.setup(blink_opts)
