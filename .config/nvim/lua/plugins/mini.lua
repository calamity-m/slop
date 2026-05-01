require("mini.icons").setup()
require("mini.statusline").setup({ use_icons = true })
require("mini.tabline").setup()
require("mini.indentscope").setup()
require("mini.notify").setup()
require("mini.cmdline").setup()
require("mini.cursorword").setup()
require("mini.hues").setup({
	background = "#101418",
	foreground = "#d7dde3",
	n_hues = 8,
	saturation = "medium",
})

require("mini.diff").setup({
	mappings = {
		apply = "",
		reset = "",
		textobject = "",
	},
})

vim.notify = require("mini.notify").make_notify()
