local haunt = require("haunt")

haunt.setup({
	picker = "fzf",
	picker_keys = {
		delete = { key = "d", mode = { "n" } },
		edit_annotation = { key = "a", mode = { "n" } },
	},
})

local api = require("haunt.api")
local picker = require("haunt.picker")
local map = vim.keymap.set
local prefix = "<leader>h"

map("n", prefix .. "a", api.annotate, { desc = "Annotate" })
map("n", prefix .. "t", api.toggle_annotation, { desc = "Toggle Annotation" })
map("n", prefix .. "T", api.toggle_all_lines, { desc = "Toggle All Annotations" })
map("n", prefix .. "d", api.delete, { desc = "Delete Bookmark" })
map("n", prefix .. "C", api.clear_all, { desc = "Delete All Bookmarks" })

map("n", prefix .. "p", api.prev, { desc = "Previous Bookmark" })
map("n", prefix .. "n", api.next, { desc = "Next Bookmark" })

map("n", "<leader>fh", picker.show, { desc = "Show Bookmarks" })

map("n", prefix .. "q", api.to_quickfix, { desc = "Bookmarks To Quickfix" })
map("n", prefix .. "Q", function()
	api.to_quickfix({ current_buffer = true })
end, { desc = "Buffer Bookmarks To Quickfix" })

map("n", prefix .. "y", function()
	api.yank_locations({ current_buffer = true })
end, { desc = "Yank Buffer Bookmarks" })
map("n", prefix .. "Y", api.yank_locations, { desc = "Yank All Bookmarks" })
