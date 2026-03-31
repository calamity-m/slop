--
--  _ __   _____   _____ (_)_ __ ___
-- | '_ \ / _ \ \ / / _ \| | '_ ` _ \
-- | | | |  __/\ V / (_) | | | | | | |
-- |_| |_|\___| \_/ \___/|_|_| |_| |_|
--

-- ===============
-- CORE
-- ===============

-- leader keys must be set before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ===============
-- OPTIONS
-- ===============

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.showtabline = 2

vim.o.mousescroll = "ver:25,hor:6"
vim.o.switchbuf = "usetab"

-- clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ===============
-- DIAGNOSTICS
-- ===============

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	virtual_text = true,
	update_in_insert = true,
})

-- ===============
-- COLORSCHEME
-- ===============

vim.pack.add({
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/webhooked/kanso.nvim" },
}, { confirm = false })

vim.cmd.colorscheme("kanagawa-dragon")
-- ===============
-- PLUGINS
-- ===============

vim.pack.add({
	-- shared dependencies
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/rcarriga/nvim-notify" },

	-- editor UI / navigation
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
	{ src = "https://github.com/akinsho/bufferline.nvim" },
	{ src = "https://github.com/folke/noice.nvim" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },

	-- syntax / editing
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
	{ src = "https://github.com/smjonas/inc-rename.nvim" },
	{ src = "https://github.com/jake-stewart/multicursor.nvim" },

	-- lsp / formatting
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/stevearc/conform.nvim" },
})

-- ===============
-- TREESITTER
-- ===============

require("nvim-treesitter").setup({})

require("nvim-treesitter").install({
	"rust",
	"javascript",
	"zig",
	"python",
	"go",
	"markdown",
	"lua",
	"json",
	"toml",
	"typescript",
	"tsx",
})

-- ===============
-- BLINK
-- ===============

require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	appearance = {
		nerd_font_variant = "mono",
		use_nvim_cmp_as_default = true,
	},
	completion = {
		documentation = { auto_show = true },
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})

-- ===============
-- INC-RENAME
-- ===============

require("inc_rename").setup()

-- ===============
-- MULTICURSOR
-- ===============

local mc = require("multicursor-nvim")

mc.setup()

-- ===============
-- WHICH-KEY
-- ===============

local wk = require("which-key")

wk.setup({})

wk.add({
	{ "<leader>b", group = "Buffers" },
	{ "<leader>c", group = "Code / Change" },
	{ "<leader>d", group = "Diagnostics" },
	{ "<leader>e", group = "Explorer" },
	{ "<leader>g", group = "Goto / LSP" },
	{ "<leader>s", group = "Symbols" },
	{ "<leader>t", group = "Tabs" },
	{ "<leader>m", group = "Multicursor" },
})

-- ===============
-- NEO-TREE
-- ===============

require("neo-tree").setup({
	window = {
		width = 30,
	},
	filesystem = {
		follow_current_file = {
			enabled = true,
			leave_dirs_open = false,
		},
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
		},
	},
	git_status = {
		symbols = {
			added = "",
			modified = "",
			deleted = "✖",
			renamed = "󰁕",
			untracked = "",
			ignored = "",
			unstaged = "󰄱",
			staged = "",
			conflict = "",
		},
	},
})

-- ===============
-- BUFFERLINE
-- ===============

require("bufferline").setup({
	options = {
		mode = "buffers",
		always_show_bufferline = true,
		diagnostics = "nvim_lsp",
		separator_style = "slant",
		show_close_icon = false,
		show_buffer_close_icons = true,
		offsets = {
			{
				filetype = "neo-tree",
				text = "Explorer",
				text_align = "left",
				separator = true,
			},
		},
	},
})

-- ===============
-- NOICE
-- ===============

require("noice").setup({
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

-- ===============
-- FZF-LUA
-- ===============

local fzf = require("fzf-lua")

fzf.setup({
	"fzf-native", -- base profile
	winopts = {
		height = 0.85,
		width = 0.80,
		row = 0.35,
		col = 0.50,
		border = "rounded",
		preview = {
			layout = "flex",
			flip_columns = 120,
			scrollbar = "float",
		},
	},
	keymap = {
		fzf = {
			["ctrl-q"] = "select-all+accept",
		},
	},
	grep = {
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/' --max-columns=4096 -e",
	},
})

-- A custom "git global" picker that works like FzfLua.globals
-- but for git operations. You type a prefix character and hit enter,
-- and it routes you to the right git picker.
--
-- Prefixes:
--   (empty/enter)  → git_files    (search tracked files)
--   @              → git_stash    (browse stash entries)
--   #              → git_commits  (browse commit log)
--   !              → git_branches (switch/view branches)
--   ?              → git_status   (see changed files)
--
local function git_global()
	local fzf = require("fzf-lua")

	-- fzf.fzf_exec is the low-level way to create a custom fzf picker.
	-- The first argument is a "content provider" — a function that feeds
	-- lines into fzf for the user to filter/select. Since we don't
	-- actually want to list anything (we just want the prompt), we call
	-- fzf_cb() immediately with no arguments, which signals "no items,
	-- I'm done." This gives us an empty fzf window with just a prompt.
	fzf.fzf_exec(function(fzf_cb)
		fzf_cb() -- close the feed immediately; we only care about the typed query
	end, {

		-- The text shown before the cursor in the fzf window.
		-- This acts as a hint so you remember what prefixes do what.
		prompt = "Git [@ stash | # commits | ! branches | ? status]> ",

		-- "actions" define what happens when you press a key in fzf.
		-- "default" is the action for pressing <enter>.
		actions = {
			["default"] = function(_, opts)
				-- opts.__call_opts.query holds whatever the user typed into
				-- the fzf prompt before pressing enter. For example if they
				-- typed "#" and hit enter, query will be "#".
				local query = opts.__call_opts.query or ""

				if query == "" or query:match("^%s*$") then
					-- Nothing typed (or just whitespace) → open git file finder.
					-- This is the "default" behaviour, like how globals defaults
					-- to file search.
					fzf.git_files()
				elseif query:sub(1, 1) == "@" then
					-- Starts with @ → show git stash list
					-- query:sub(1, 1) grabs just the first character
					fzf.git_stash()
				elseif query:sub(1, 1) == "#" then
					-- Starts with # → show git commit log
					fzf.git_commits()
				elseif query:sub(1, 1) == "!" then
					-- Starts with ! → show git branches
					fzf.git_branches()
				elseif query:sub(1, 1) == "?" then
					-- Starts with ? → show git status (changed/staged files)
					fzf.git_status()
				else
					-- If they typed something that doesn't match a prefix,
					-- assume they want to search git files with that text
					-- already filled in as a query. For example typing "README"
					-- and pressing enter would open git_files pre-filtered
					-- to "README".
					fzf.git_files({ query = query })
				end
			end,
		},

		-- Window appearance for this initial prompt picker.
		-- We make it small since it's just a dispatch prompt,
		-- not showing any file list.
		--    winopts = {
		--      height = 0.4,  -- 40% of editor height
		--      width  = 0.5,  -- 50% of editor width
		--      row    = 0.3,  -- positioned 30% from top
		--      border = "rounded",
		--      preview = {
		--        hidden = "hidden", -- no preview pane; there's nothing to preview
		--      },
		--    },
	})
end

-- ===============
-- LSP
-- ===============

vim.lsp.enable({
	"rust_analyzer",
	"gopls",
	"lua_ls",
	"ty",
})

-- ===============
-- CONFORM
-- ===============

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = {
			"goimports",
			"gofmt",
			stop_after_first = true,
		},
		python = { "ruff" },
		rust = { "rustfmt" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
	},

	default_format_opts = {
		lsp_format = "fallback",
	},

	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},

	format_after_save = {
		lsp_format = "fallback",
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- ===============
-- COMMAND ALIASES
-- ===============

local typos = { "W", "Q", "Wq", "WQ", "Wa", "WA", "Qa", "QA", "Wqa", "WQA", "WQa", "WqA" }
for _, cmd in ipairs(typos) do
	vim.api.nvim_create_user_command(cmd, function(opts)
		vim.cmd(cmd:lower() .. (opts.bang and "!" or ""))
	end, { bang = true })
end

-- ===============
-- KEYMAPS
-- ===============

local map = vim.keymap.set

-- -----------------
-- General
-- -----------------

-- clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })

-- save / quit
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write File" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit Window" })

-- -----------------
-- Window navigation
-- -----------------

map("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

-- optional: resize splits
map("n", "<leader><left>", "<cmd>vertical resize -4<CR>", { desc = "Resize Window Left" })
map("n", "<leader><right>", "<cmd>vertical resize +4<CR>", { desc = "Resize Window Right" })
map("n", "<leader><up>", "<cmd>resize +2<CR>", { desc = "Resize Window Up" })
map("n", "<leader><down>", "<cmd>resize -2<CR>", { desc = "Resize Window Down" })

-- -----------------
-- Neo-tree
-- -----------------

-- toggle / focus filesystem tree
map("n", "<leader>e", "<cmd>Neotree toggle filesystem reveal left<CR>", { desc = "Explorer Toggle" })
map("n", "<leader>o", "<cmd>Neotree focus filesystem left<CR>", { desc = "Explorer Focus" })

-- useful extra sources
map("n", "<leader>be", "<cmd>Neotree show buffers right<CR>", { desc = "Buffer Explorer" })
map("n", "<leader>ge", "<cmd>Neotree show git_status float<CR>", { desc = "Git Explorer" })

-- reveal current file in the tree
map("n", "<leader>er", "<cmd>Neotree reveal filesystem left<CR>", { desc = "Explorer Reveal Current File" })

-- -----------------
-- Fzf-lua
-- -----------------

map("n", "<leader>ff", fzf.global, { desc = "Fzf Global" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fh", fzf.help_tags, { desc = "Help tags" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume last" })
map("n", "<leader>fo", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Diagnostics" })
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Symbols" })

map("n", "gd", fzf.lsp_definitions, { desc = "Go to definition" })
map("n", "gr", fzf.lsp_references, { desc = "References" })

map("n", "<leader>fG", git_global, { desc = "Git global picker" })

-- -----------------
-- Buffers
-- -----------------

map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })

map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete Other Buffers" })

-- direct jumps
map("n", "<leader>b1", "<cmd>BufferLineGoToBuffer 1<CR>", { desc = "Go to Buffer 1" })
map("n", "<leader>b2", "<cmd>BufferLineGoToBuffer 2<CR>", { desc = "Go to Buffer 2" })
map("n", "<leader>b3", "<cmd>BufferLineGoToBuffer 3<CR>", { desc = "Go to Buffer 3" })
map("n", "<leader>b4", "<cmd>BufferLineGoToBuffer 4<CR>", { desc = "Go to Buffer 4" })
map("n", "<leader>b5", "<cmd>BufferLineGoToBuffer 5<CR>", { desc = "Go to Buffer 5" })

-- -----------------
-- Native tabpages
-- -----------------
-- keep these for workspace-style tabs, not normal file switching

map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New Tab" })
map("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close Tab" })
map("n", "<leader>tl", "<cmd>tabnext<CR>", { desc = "Next Tab" })
map("n", "<leader>th", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })

-- -----------------
-- LSP navigation
-- -----------------

map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Goto References" })
map("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })

map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })

-- keep signature help off <C-k> because that already moves windows
map("n", "<leader>cs", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- -----------------
-- LSP actions
-- -----------------

map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })

-- inc-rename
vim.keymap.set("n", "<leader>cr", function()
	return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

-- lsp buf
map("n", "<leader>gg", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>gh", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "<leader>gr", fzf.lsp_references, { desc = "References" })
map("n", "<leader>gi", fzf.lsp_implementations, { desc = "Implementation" })
map("n", "<leader>gt", fzf.lsp_typedefs, { desc = "Type Definition" })

-- -----------------
-- Symbols / search-ish LSP helpers
-- -----------------

map("n", "<leader>ss", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
map("n", "<leader>sS", function()
	vim.lsp.buf.workspace_symbol("")
end, { desc = "Workspace Symbols" })

-- -----------------
-- Diagnostics
-- -----------------

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics to Location List" })

-- optional: all diagnostics in quickfix instead
map("n", "<leader>dQ", vim.diagnostic.setqflist, { desc = "Diagnostics to Quickfix" })

-- -----------------
-- Multicursor
-- -----------------

-- Add or skip cursor above/below the main cursor.
map({ "n", "x" }, "<C-up>", function()
	mc.lineAddCursor(-1)
end)
map({ "n", "x" }, "<C-down>", function()
	mc.lineAddCursor(1)
end)
map({ "n", "x" }, "<leader><up>", function()
	mc.lineSkipCursor(-1)
end, { desc = "Skip above line" })
map({ "n", "x" }, "<leader><down>", function()
	mc.lineSkipCursor(1)
end, { desc = "Skip next line" })

-- Add or skip adding a new cursor by matching word/selection
map({ "n", "x" }, "<leader>mn", function()
	mc.matchAddCursor(1)
end, { desc = "Add cursor at next match" })
map({ "n", "x" }, "<leader>ms", function()
	mc.matchSkipCursor(1)
end, { desc = "Skip next match" })
map({ "n", "x" }, "<leader>mN", function()
	mc.matchAddCursor(-1)
end, { desc = "Add cursor at previous match" })
map({ "n", "x" }, "<leader>mS", function()
	mc.matchSkipCursor(-1)
end, { desc = "Skip previous match" })

-- Add and remove cursors with control + left click.
map("n", "<c-leftmouse>", mc.handleMouse)
map("n", "<c-leftdrag>", mc.handleMouseDrag)
map("n", "<c-leftrelease>", mc.handleMouseRelease)

-- Disable and enable cursors.
map({ "n", "x" }, "<c-q>", mc.toggleCursor)

-- Mappings defined in a keymap layer only apply when there are
-- multiple cursors. This lets you have overlapping mappings.
mc.addKeymapLayer(function(layerSet)
	-- Select a different cursor as the main one.
	layerSet({ "n", "x" }, "<left>", mc.prevCursor)
	layerSet({ "n", "x" }, "<right>", mc.nextCursor)

	-- Delete the main cursor.
	layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

	-- Enable and clear cursors using escape.
	layerSet("n", "<esc>", function()
		if not mc.cursorsEnabled() then
			mc.enableCursors()
		else
			mc.clearCursors()
		end
	end)
end)

-- -----------------
-- Black hole register helpers
-- -----------------
-- delete/change without overwriting your current yank/clipboard

map("v", "<leader>d", '"_d', { desc = "Delete Without Yank" })
map("v", "<leader>c", '"_c', { desc = "Change Without Yank" })
map("n", "x", '"_x', { desc = "Delete Char Without Yank" })

-- paste over selection without clobbering unnamed register
map("v", "p", '"_dP', { desc = "Paste Without Yank Replace" })
