vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
vim.opt.listchars = { tab = "> ", trail = ".", nbsp = "+" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.showtabline = 2

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
vim.opt.foldlevel = 99

vim.o.mousescroll = "ver:25,hor:6"
vim.o.switchbuf = "useopen,usetab"

vim.o.inccommand = "split"

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	update_in_insert = true,
	virtual_lines = {
		wrap = true, -- Wrap the virtual text lines
	},
	virtual_text = {
		wrap = true,
	},
})

-- ui2
require("vim._core.ui2").enable({})

vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

local typos = { "W", "Q", "Wq", "WQ", "Wa", "WA", "Qa", "QA", "Wqa", "WQA", "WQa", "WqA" }
for _, cmd in ipairs(typos) do
	vim.api.nvim_create_user_command(cmd, function(opts)
		vim.cmd(cmd:lower() .. (opts.bang and "!" or ""))
	end, { bang = true })
end
