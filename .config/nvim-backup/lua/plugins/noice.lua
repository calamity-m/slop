local noice = require("noice")

noice.setup({
	views = {
		cmdline_popup = {
			position = {
				row = "50%",
				col = "50%",
			},
			size = {
				width = "75%",
				height = "auto",
			},
		},
	},
	presets = {
		command_palette = true,
		inc_rename = true,
	},
})
