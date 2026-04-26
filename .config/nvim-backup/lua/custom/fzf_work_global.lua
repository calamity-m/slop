local fzf = require("fzf-lua")
local fzf_actions = require("fzf-lua.actions")
local fzf_config = require("fzf-lua.config")
local libuv = require("fzf-lua.libuv")
local shell = require("fzf-lua.shell")
local utils = require("fzf-lua.utils")
local haunt_api = require("haunt.api")
local haunt_picker_utils = require("haunt.picker.utils")

local M = {}

local state = {
	haunt_lookup = {},
	providers_registered = false,
}

local function trim_prefixed_query(query, prefix)
	if type(query) ~= "string" then
		return ""
	end

	if query:sub(1, #prefix) == prefix then
		return vim.trim(query:sub(#prefix + 1))
	end

	return query
end

local function is_haunt_query(query)
	return type(query) == "string" and query:sub(1, 1) == "#"
end

local function current_query(opts)
	return (((opts or {}).__call_opts or {}).query or "")
end

local function normalized_entry(entry)
	return utils.strip_ansi_coloring(entry or "")
end

local function selected_haunt_item_from_entry(entry)
	return state.haunt_lookup[normalized_entry(entry)]
end

local function selected_haunt_item_from_info()
	local info = fzf.get_info()
	if not is_haunt_query(info.query or "") then
		return nil, ""
	end

	local entry = info.selected
	if not entry or entry == "" then
		local ok, line = pcall(vim.api.nvim_get_current_line)
		if ok then
			entry = line
		end
	end

	return selected_haunt_item_from_entry(entry), info.query or ""
end

local function reopen(query)
	vim.schedule(function()
		M.open({ query = query })
	end)
end

local function delete_haunt_item(item, query)
	if not item then
		return
	end

	local success = haunt_api.delete_by_id(item.id)
	if not success then
		vim.notify("haunt.nvim: Failed to delete bookmark", vim.log.levels.WARN)
		return
	end

	local remaining = haunt_api.get_bookmarks()
	if #remaining == 0 then
		vim.notify("haunt.nvim: No bookmarks remaining", vim.log.levels.INFO)
		return
	end

	reopen(query)
end

local function edit_haunt_item(item, query)
	if not item then
		return
	end

	haunt_picker_utils.handle_edit_annotation({
		item = item,
		close_picker = function() end,
		reopen_picker = function()
			reopen(query)
		end,
	})
end

local function default_action(selected, opts)
	local query = current_query(opts)
	if is_haunt_query(query) then
		local item = selected_haunt_item_from_entry(selected and selected[1])
		if item then
			haunt_picker_utils.jump_to_bookmark(item)
			return
		end
	end

	fzf_actions.file_edit_or_qf(selected, opts)
end

local function grep_command_for_query(query)
	local search = trim_prefixed_query(query, "@")
	if search == "" then
		return utils.shell_nop()
	end

	local rg_opts = fzf_config.globals.grep.rg_opts
	return string.format("rg %s %s", rg_opts, libuv.shellescape(search))
end

local function build_grep_command(query_field)
	return shell.stringify_cmd(function(items)
		return grep_command_for_query(items[1])
	end, fzf_config.globals.grep, query_field or "{q}")
end

local function build_haunt_entries()
	local lookup = {}
	local entries = {}
	local bookmarks = haunt_api.get_bookmarks()
	local items = haunt_picker_utils.build_picker_items(bookmarks)

	for _, item in ipairs(items) do
		local entry = string.format("%s:%d:1", item.relpath, item.line)
		if item.note and item.note ~= "" then
			entry = entry .. ": " .. item.note:gsub("[\r\n]+", " ")
		end

		lookup[entry] = item
		table.insert(entries, entry)
	end

	state.haunt_lookup = lookup
	return entries
end

local function register_providers()
	if state.providers_registered then
		return
	end

	fzf.haunt_global = function(opts)
		opts = vim.tbl_deep_extend("force", opts or {}, {
			_type = "file",
		})

		return fzf.fzf_exec(build_haunt_entries(), opts)
	end

	fzf.work_global_grep = function(opts)
		opts = vim.tbl_deep_extend("force", opts or {}, {
			_type = "file",
		})

		return fzf.fzf_exec(build_grep_command("{q}"), opts)
	end

	state.providers_registered = true
end

local function attach_haunt_normal_mode_maps(winctx, user_on_create)
	if type(user_on_create) == "function" then
		user_on_create(winctx)
	end

	local bufnr = winctx.bufnr
	if not bufnr then
		return
	end

	vim.keymap.set("n", "d", function()
		local item, query = selected_haunt_item_from_info()
		if not item then
			return
		end

		fzf.win.close()
		vim.schedule(function()
			delete_haunt_item(item, query)
		end)
	end, {
		buffer = bufnr,
		nowait = true,
		silent = true,
		desc = "Delete Haunt Bookmark",
	})

	vim.keymap.set("n", "a", function()
		local item, query = selected_haunt_item_from_info()
		if not item then
			return
		end

		fzf.win.close()
		vim.schedule(function()
			edit_haunt_item(item, query)
		end)
	end, {
		buffer = bufnr,
		nowait = true,
		silent = true,
		desc = "Edit Haunt Annotation",
	})
end

local function build_grep_reload_bind(opts)
	local grep_reload_cmd = build_grep_command("{q}")

	return "--bind=" .. libuv.shellescape("change:+transform:" .. shell.stringify_data(function(args)
		local query = args[1] or ""
		if query:sub(1, 1) ~= "@" then
			return ""
		end

		local search = trim_prefixed_query(query, "@")
		if search == "" then
			return string.format("reload(%s)", grep_reload_cmd)
		end

		return string.format("reload(%s)+search(%s)", grep_reload_cmd, search)
	end, opts, "{q}"))
end

local function build_actions()
	local actions = vim.deepcopy(fzf_config.globals.actions.files)
	actions["enter"] = default_action
	return actions
end

function M.open(opts)
	register_providers()

	opts = opts or {}

	local user_on_create = utils.map_get(opts, "winopts.on_create")
	local merged = vim.tbl_deep_extend("force", {
		prompt = "Find [files | @ content | # haunt]> ",
		header = false,
		actions = build_actions(),
		pickers = {
			{ "files", desc = "Files" },
			{ "work_global_grep", prefix = "@", desc = "Content" },
			{ "haunt_global", prefix = "#", desc = "Haunt" },
		},
		winopts = {
			on_create = function(winctx)
				attach_haunt_normal_mode_maps(winctx, user_on_create)
			end,
		},
	}, opts)

	merged._fzf_cli_args = merged._fzf_cli_args or {}
	table.insert(merged._fzf_cli_args, build_grep_reload_bind(merged))

	fzf.global(merged)
end

return M
