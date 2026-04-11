local indent = require("blink.indent")
local map = vim.keymap.set

indent.setup({
	static = {
		enabled = false,
		char = "╎",
		highlights = { "BlinkIndent" },
	},
	scope = {
		char = "╎",
		highlights = {
			"BlinkIndent",
		},
	},
})

map("n", "<C-n>", function()
	indent.enable(not indent.is_enabled())
end, { desc = "Toggle Indent Guides" })
