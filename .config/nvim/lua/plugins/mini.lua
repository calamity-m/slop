require("mini.icons").setup()
local mini_starter = require("mini.starter")
mini_starter.setup({
	evaluate_single = true,
	items = {
		mini_starter.sections.recent_files(10, true, false),
		mini_starter.sections.recent_files(10, false, true),
	},
	content_hooks = {
		mini_starter.gen_hook.adding_bullet(),
		mini_starter.gen_hook.indexing("all", { "Builtin actions" }),
		mini_starter.gen_hook.padding(3, 2),
	},
})
require("mini.statusline").setup({ use_icons = true })
require("mini.tabline").setup()
require("mini.indentscope").setup()
require("mini.notify").setup()
require("mini.cmdline").setup()
require("mini.cursorword").setup()
require("mini.jump2d").setup()
require("mini.move").setup()
require("mini.pairs").setup()
require("mini.splitjoin").setup({
	mappings = {
		toggle = "<leader>gS",
	},
})
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

local mini_map = require("mini.map")
mini_map.setup({
	integrations = {
		mini_map.gen_integration.diagnostic({
			error = "DiagnosticFloatingError",
			warn = "DiagnosticFloatingWarn",
			info = "DiagnosticFloatingInfo",
			hint = "DiagnosticFloatingHint",
		}),
		mini_map.gen_integration.gitsigns(),
	},
	symbols = {
		encode = mini_map.gen_encode_symbols.dot("4x2"),
		scroll_line = "◆",
		scroll_view = "·",
	},
	window = {
		width = 5,
	},
})
vim.keymap.set("n", "<leader>tm", mini_map.toggle, { desc = "Toggle Minimap" })

vim.notify = require("mini.notify").make_notify()
