local haunt = require("haunt")

haunt.setup({
	picker = "fzf",
	picker_keys = {
		-- ctrl-prefixed so typing in the fzf filter can't fire them by accident
		delete = { key = "ctrl-d", mode = { "n" } },
		edit_annotation = { key = "ctrl-e", mode = { "n" } },
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

--- Convert a fzf picker entry ("<abs file>:<line>:<col>[ note]") into one
--- sidekick.nvim-style location line: `- @/{relpath} :L{line} - "{note}"`.
--- Mirrors haunt.sidekick formatting locally so copying needs no sidekick.nvim.
local function entry_to_sidekick(entry)
	local file, line, _, note = entry:match("^(.-):(%d+):(%d+)%s*(.*)$")
	if not file then
		return nil
	end
	local out = string.format("- @/%s :L%s", vim.fn.fnamemodify(file, ":."), line)
	if note ~= "" then
		out = out .. string.format(' - "%s"', note)
	end
	return out
end

--- Yank the picker's selected bookmarks to the system clipboard in
--- sidekick.nvim location format, leaving the picker open (fzf exec_silent).
--- `selected` holds the fzf `{+}` entries: marked items, or the current line.
local function copy_selected_sidekick(selected)
	local lines = {}
	for _, entry in ipairs(selected or {}) do
		local formatted = entry_to_sidekick(entry)
		if formatted then
			table.insert(lines, formatted)
		end
	end
	if #lines == 0 then
		return
	end
	vim.fn.setreg("+", table.concat(lines, "\n") .. "\n")
	vim.notify(string.format("haunt: copied %d bookmark(s) to clipboard", #lines))
end

local function show_picker()
	picker.show({
		-- fzf-lua renders this above the list; keep it in sync with the actions
		-- below and haunt's picker_keys (delete = d, edit_annotation = a).
		header = "<cr> jump | ctrl-d delete | ctrl-e annotate | ctrl-y copy",
		actions = {
			-- exec_silent keeps the picker open after copying.
			["ctrl-y"] = { fn = copy_selected_sidekick, exec_silent = true },
		},
	})
end

map("n", prefix .. "f", show_picker, { desc = "Show Bookmarks" })
map("n", "<leader>fh", show_picker, { desc = "Show Bookmarks" })

map("n", prefix .. "q", api.to_quickfix, { desc = "Bookmarks To Quickfix" })
map("n", prefix .. "Q", function()
	api.to_quickfix({ current_buffer = true })
end, { desc = "Buffer Bookmarks To Quickfix" })

map("n", prefix .. "y", function()
	api.yank_locations({ current_buffer = true })
end, { desc = "Yank Buffer Bookmarks" })
map("n", prefix .. "Y", api.yank_locations, { desc = "Yank All Bookmarks" })
