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
local picker_utils = require("haunt.picker.utils")
local sidekick = require("haunt.sidekick")
local map = vim.keymap.set
local prefix = "<leader>h"

map("n", prefix .. "a", api.annotate, { desc = "Annotate" })
map("n", prefix .. "t", api.toggle_annotation, { desc = "Toggle Annotation" })
map("n", prefix .. "T", api.toggle_all_lines, { desc = "Toggle All Annotations" })
map("n", prefix .. "d", api.delete, { desc = "Delete Bookmark" })
map("n", prefix .. "C", api.clear_all, { desc = "Delete All Bookmarks" })

map("n", prefix .. "p", api.prev, { desc = "Previous Bookmark" })
map("n", prefix .. "n", api.next, { desc = "Next Bookmark" })

local function bookmark_to_sidekick(bookmark)
	local relpath = vim.fn.fnamemodify(bookmark.file, ":.")
	if relpath == "" then
		relpath = bookmark.file
	end

	local out = string.format("- @/%s :L%d", relpath, bookmark.line)
	if bookmark.note and bookmark.note ~= "" then
		out = out .. string.format(' - "%s"', bookmark.note)
	end
	return out
end

local function get_sorted_bookmarks()
	local bookmarks = vim.deepcopy(api.get_bookmarks())
	table.sort(bookmarks, function(a, b)
		if a.file == b.file then
			return a.line < b.line
		end
		return a.file < b.file
	end)
	return bookmarks
end

local function copy_all_sidekick()
	local locations = sidekick.get_locations()
	if locations == "" then
		return
	end

	local lines = vim.split(locations, "\n", { plain = true, trimempty = true })
	vim.fn.setreg("+", locations .. "\n")
	vim.notify(string.format("haunt: copied %d annotation(s) to clipboard", #lines))
end

local show_picker

local function handle_delete(item)
	if not item then
		return
	end

	local success = api.delete_by_id(item.id)
	if not success then
		vim.notify("haunt.nvim: Failed to delete bookmark", vim.log.levels.WARN)
		return
	end

	if #api.get_bookmarks() == 0 then
		vim.notify("haunt.nvim: No bookmarks remaining", vim.log.levels.INFO)
		return
	end

	show_picker()
end

local function handle_edit_annotation(item)
	picker_utils.handle_edit_annotation({
		item = item,
		close_picker = function() end,
		reopen_picker = show_picker,
	})
end

local function handle_clear_all()
	api.clear_all()
end

show_picker = function()
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		vim.notify("haunt.nvim: fzf-lua is not available", vim.log.levels.WARN)
		return
	end

	local bookmarks = get_sorted_bookmarks()
	if #bookmarks == 0 then
		vim.notify("haunt.nvim: No bookmarks found", vim.log.levels.INFO)
		return
	end

	local display_list = {}
	local lookup = {}
	for _, bookmark in ipairs(bookmarks) do
		local label = bookmark_to_sidekick(bookmark)
		display_list[#display_list + 1] = label
		lookup[label] = {
			file = bookmark.file,
			id = bookmark.id,
			line = bookmark.line,
			note = bookmark.note,
			pos = { bookmark.line, 0 },
		}
	end

	fzf.fzf_exec(display_list, {
		prompt = "Hauntings> ",
		previewer = "builtin",
		header = "<cr> jump | ctrl-d delete | ctrl-e annotate | ctrl-y copy all | ctrl-x delete all",
		_fmt = {
			from = function(entry)
				local file, line = entry:match("^%- @/(.-) :L(%d+)")
				return file and string.format("%s:%s:1", file, line) or entry
			end,
		},
		actions = {
			["default"] = function(selected)
				local item = selected and lookup[selected[1]]
				if item then
					picker_utils.jump_to_bookmark(item)
				end
			end,
			["ctrl-d"] = function(selected)
				handle_delete(selected and lookup[selected[1]])
			end,
			["ctrl-e"] = function(selected)
				handle_edit_annotation(selected and lookup[selected[1]])
			end,
			["ctrl-y"] = { fn = copy_all_sidekick, exec_silent = true },
			["ctrl-x"] = handle_clear_all,
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
