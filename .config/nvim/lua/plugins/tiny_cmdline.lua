vim.o.cmdheight = 0
require("tiny-cmdline").setup({
	native_types = {},
	on_reposition = require("tiny-cmdline").adapters.blink,
})
