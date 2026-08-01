-- Umber: muted earth-tone dark colorscheme derived from a 16-color terminal palette.
vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd.syntax("reset")
end
vim.o.background = "dark"
vim.g.colors_name = "umber"

local c = {
	bg = "#000000",
	fg = "#9a8b7a",

	black = "#16130f",
	red = "#796551",
	green = "#547967",
	yellow = "#6d8257",
	blue = "#6d5782",
	magenta = "#82576d",
	cyan = "#506171",
	white = "#93897f",

	bright_black = "#4c4744",
	bright_red = "#7e6c59",
	bright_green = "#4f7060",
	bright_yellow = "#6d8257",
	bright_blue = "#6d5782",
	bright_magenta = "#82576d",
	bright_cyan = "#536577",
	bright_white = "#c8beb4",
}

local hi = function(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-- Editor UI
hi("Normal", { fg = c.fg, bg = c.bg })
hi("NormalFloat", { fg = c.fg, bg = c.black })
hi("FloatBorder", { fg = c.bright_black, bg = c.black })
hi("FloatTitle", { fg = c.fg, bg = c.black })
hi("Cursor", { fg = c.bg, bg = c.fg })
hi("CursorLine", { bg = c.black })
hi("CursorLineNr", { fg = c.bright_white, bold = true })
hi("LineNr", { fg = c.bright_black })
hi("SignColumn", { bg = c.bg })
hi("ColorColumn", { bg = c.black })
hi("VertSplit", { fg = c.black })
hi("WinSeparator", { fg = c.black })
hi("Visual", { bg = c.bright_black })
hi("VisualNOS", { bg = c.bright_black })
hi("Search", { fg = c.bg, bg = c.yellow })
hi("IncSearch", { fg = c.bg, bg = c.bright_yellow })
hi("CurSearch", { link = "IncSearch" })
hi("Pmenu", { fg = c.fg, bg = c.black })
hi("PmenuSel", { fg = c.bg, bg = c.fg })
hi("PmenuSbar", { bg = c.black })
hi("PmenuThumb", { bg = c.bright_black })
hi("StatusLine", { fg = c.fg, bg = c.black })
hi("StatusLineNC", { fg = c.bright_black, bg = c.black })
hi("TabLine", { fg = c.bright_black, bg = c.black })
hi("TabLineFill", { bg = c.black })
hi("TabLineSel", { fg = c.bg, bg = c.fg })
hi("MatchParen", { fg = c.bright_yellow, bold = true })
hi("NonText", { fg = c.bright_black })
hi("Whitespace", { fg = c.bright_black })
hi("EndOfBuffer", { fg = c.bg })
hi("Folded", { fg = c.bright_black, bg = c.black })
hi("FoldColumn", { fg = c.bright_black, bg = c.bg })
hi("Title", { fg = c.bright_white, bold = true })
hi("Directory", { fg = c.blue })

-- Syntax
hi("Comment", { fg = c.bright_black, italic = true })
hi("Constant", { fg = c.magenta })
hi("String", { fg = c.green })
hi("Character", { fg = c.green })
hi("Number", { fg = c.magenta })
hi("Boolean", { fg = c.magenta })
hi("Float", { fg = c.magenta })
hi("Identifier", { fg = c.fg })
hi("Function", { fg = c.blue })
hi("Statement", { fg = c.yellow })
hi("Conditional", { fg = c.yellow })
hi("Repeat", { fg = c.yellow })
hi("Label", { fg = c.yellow })
hi("Operator", { fg = c.fg })
hi("Keyword", { fg = c.yellow })
hi("Exception", { fg = c.red })
hi("PreProc", { fg = c.cyan })
hi("Include", { fg = c.cyan })
hi("Define", { fg = c.cyan })
hi("Macro", { fg = c.cyan })
hi("Type", { fg = c.cyan })
hi("StorageClass", { fg = c.cyan })
hi("Structure", { fg = c.cyan })
hi("Typedef", { fg = c.cyan })
hi("Special", { fg = c.bright_magenta })
hi("SpecialChar", { fg = c.bright_magenta })
hi("Delimiter", { fg = c.fg })
hi("Underlined", { underline = true })
hi("Error", { fg = c.bright_white, bg = c.red })
hi("Todo", { fg = c.bg, bg = c.yellow, bold = true })

-- Diff
hi("DiffAdd", { fg = c.green, bg = c.bg })
hi("DiffChange", { fg = c.yellow, bg = c.bg })
hi("DiffDelete", { fg = c.red, bg = c.bg })
hi("DiffText", { fg = c.bright_yellow, bg = c.bg, bold = true })

-- Diagnostics
hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn", { fg = c.yellow })
hi("DiagnosticInfo", { fg = c.cyan })
hi("DiagnosticHint", { fg = c.blue })
hi("DiagnosticOk", { fg = c.green })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hi("DiagnosticUnderlineInfo", { undercurl = true, sp = c.cyan })
hi("DiagnosticUnderlineHint", { undercurl = true, sp = c.blue })

-- Git signs
hi("GitSignsAdd", { fg = c.green })
hi("GitSignsChange", { fg = c.yellow })
hi("GitSignsDelete", { fg = c.red })

-- Treesitter
hi("@variable", { fg = c.fg })
hi("@variable.builtin", { fg = c.bright_magenta })
hi("@variable.parameter", { fg = c.fg, italic = true })
hi("@constant", { link = "Constant" })
hi("@constant.builtin", { fg = c.bright_magenta })
hi("@string", { link = "String" })
hi("@character", { link = "Character" })
hi("@number", { link = "Number" })
hi("@boolean", { link = "Boolean" })
hi("@function", { link = "Function" })
hi("@function.builtin", { fg = c.blue })
hi("@method", { link = "Function" })
hi("@constructor", { fg = c.cyan })
hi("@parameter", { link = "@variable.parameter" })
hi("@keyword", { link = "Keyword" })
hi("@keyword.function", { link = "Keyword" })
hi("@keyword.return", { link = "Keyword" })
hi("@keyword.conditional", { link = "Conditional" })
hi("@keyword.repeat", { link = "Repeat" })
hi("@conditional", { link = "Conditional" })
hi("@repeat", { link = "Repeat" })
hi("@type", { link = "Type" })
hi("@type.builtin", { fg = c.cyan })
hi("@module", { link = "Include" })
hi("@property", { fg = c.fg })
hi("@field", { fg = c.fg })
hi("@tag", { fg = c.yellow })
hi("@tag.attribute", { fg = c.blue })
hi("@tag.delimiter", { fg = c.bright_black })
hi("@comment", { link = "Comment" })
hi("@punctuation.delimiter", { fg = c.bright_black })
hi("@punctuation.bracket", { fg = c.bright_black })
hi("@operator", { link = "Operator" })

-- LSP semantic tokens
hi("@lsp.type.class", { link = "Type" })
hi("@lsp.type.enum", { link = "Type" })
hi("@lsp.type.interface", { link = "Type" })
hi("@lsp.type.struct", { link = "Type" })
hi("@lsp.type.parameter", { link = "@variable.parameter" })
hi("@lsp.type.property", { link = "@property" })
hi("@lsp.type.variable", { link = "@variable" })
