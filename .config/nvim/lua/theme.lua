local M = {}

local state_file = vim.fn.stdpath("data") .. "/theme-picker.json"
local legacy_state_file = vim.fn.stdpath("data") .. "/themery/state.json"

M.themes = {
	{ name = "Kanagawa Dragon", colorscheme = "kanagawa-dragon" },
	{ name = "Kanagawa Wave", colorscheme = "kanagawa-wave" },
	{ name = "Gruvbox Material (Medium)", colorscheme = "gruvbox-material", gruvbox_background = "medium" },
	{ name = "Gruvbox Material (Hard)", colorscheme = "gruvbox-material", gruvbox_background = "hard" },
	{ name = "Ember Soft", colorscheme = "ember-soft", ember_variant = "ember-soft" },
	{ name = "Kanso Mist", colorscheme = "kanso-mist" },
}

local default_theme = M.themes[2]

require("kanagawa").setup({
	minimal = false,
	foreground = {
		dark = "saturated",
	},
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none",
				},
			},
			dragon = {
				ui = {
					bg = "#1e1c1a",
					bg_dim = "#1a1818",
					bg_gutter = "none",
				},
			},
		},
	},
})

vim.g.gruvbox_material_better_performance = true

local function apply_diagnostic_highlights()
	local diagnostic_error = vim.api.nvim_get_hl(0, { name = "DiagnosticError", link = false })
	local error_color = diagnostic_error.fg

	if error_color then
		vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
			bg = "NONE",
			fg = error_color,
			sp = error_color,
			undercurl = true,
		})
	end
end

-- render-markdown.nvim heading highlights
local function blend_channel(fg, bg, alpha)
	return math.floor((fg * alpha) + (bg * (1 - alpha)) + 0.5)
end

local function blend_color(fg, bg, alpha)
	local fg_red = math.floor(fg / 0x10000) % 0x100
	local fg_green = math.floor(fg / 0x100) % 0x100
	local fg_blue = fg % 0x100
	local bg_red = math.floor(bg / 0x10000) % 0x100
	local bg_green = math.floor(bg / 0x100) % 0x100
	local bg_blue = bg % 0x100

	return string.format(
		"#%02x%02x%02x",
		blend_channel(fg_red, bg_red, alpha),
		blend_channel(fg_green, bg_green, alpha),
		blend_channel(fg_blue, bg_blue, alpha)
	)
end

local function apply_render_markdown_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	local normal_bg = normal.bg or 0x000000
	local heading_groups = {
		"@markup.heading.1.markdown",
		"@markup.heading.2.markdown",
		"@markup.heading.3.markdown",
		"@markup.heading.4.markdown",
		"@markup.heading.5.markdown",
		"@markup.heading.6.markdown",
	}
	local fallback_groups = {
		"DiagnosticError",
		"DiagnosticWarn",
		"DiagnosticInfo",
		"DiagnosticHint",
		"Function",
		"Constant",
	}

	for index = 1, 6 do
		local heading = vim.api.nvim_get_hl(0, { name = heading_groups[index], link = false })
		local fallback = vim.api.nvim_get_hl(0, { name = fallback_groups[index], link = false })
		local fg = fallback.fg or heading.fg

		if fg then
			vim.api.nvim_set_hl(0, "RenderMarkdownH" .. index, {
				fg = fg,
				bold = true,
			})
			vim.api.nvim_set_hl(0, "RenderMarkdownH" .. index .. "Bg", {
				bg = blend_color(fg, normal_bg, 0.22),
				fg = fg,
				bold = true,
			})
		end
	end
end
-- end render-markdown.nvim heading highlights

local function read_json(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok or not lines or vim.tbl_isempty(lines) then
		return nil
	end

	local decoded_ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not decoded_ok then
		return nil
	end

	return data
end

local function write_json(path, data)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	vim.fn.writefile({ vim.json.encode(data) }, path)
end

local function apply_theme_config(theme)
	if theme.gruvbox_background then
		vim.g.gruvbox_material_background = theme.gruvbox_background
	end

	if theme.ember_variant then
		require("ember").setup({ variant = theme.ember_variant })
	end
end

function M.get_theme(name)
	for _, theme in ipairs(M.themes) do
		if theme.name == name or theme.colorscheme == name then
			return theme
		end
	end
end

function M.apply(theme, opts)
	opts = opts or {}

	if type(theme) == "string" then
		theme = M.get_theme(theme)
	end

	if not theme then
		return false
	end

	apply_theme_config(theme)
	vim.cmd.colorscheme(theme.colorscheme)
	apply_diagnostic_highlights()
	apply_render_markdown_highlights()

	if opts.persist ~= false then
		write_json(state_file, {
			name = theme.name,
			colorscheme = theme.colorscheme,
		})
	end

	return true
end

function M.load_saved()
	local state = read_json(state_file) or read_json(legacy_state_file)
	local theme = state and M.get_theme(state.name or state.colorscheme) or default_theme

	if not theme then
		theme = default_theme
	end

	M.apply(theme, { persist = false })
end

function M.pick()
	local fzf = require("fzf-lua")
	local entries = {}
	local current = vim.g.colors_name or ""

	for _, theme in ipairs(M.themes) do
		local prefix = theme.colorscheme == current and "* " or "  "
		table.insert(entries, prefix .. theme.name)
	end

	fzf.fzf_exec(entries, {
		prompt = "Themes> ",
		actions = {
			["default"] = function(selected)
				if not selected or not selected[1] then
					return
				end

				local name = selected[1]:gsub("^%*%s+", ""):gsub("^%s+", "")
				M.apply(name)
			end,
		},
	})
end

vim.api.nvim_create_user_command("Theme", function()
	M.pick()
end, {})

vim.keymap.set("n", "<leader>ft", M.pick, { desc = "Themes" })

M.load_saved()

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ThemeHighlights", { clear = true }),
	callback = apply_diagnostic_highlights,
})

return M
