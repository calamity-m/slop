local dropbar_configs = require("dropbar.configs")
local default_bar_enable = dropbar_configs.opts.bar.enable
local breadcrumbs_enabled = true

require("dropbar").setup({
	bar = {
		enable = function(buf, win, info)
			return breadcrumbs_enabled and dropbar_configs.eval(default_bar_enable, buf, win, info)
		end,
	},
})

local dropbar_api = require("dropbar.api")
local dropbar_utils = require("dropbar.utils")

local function toggle_breadcrumbs()
	breadcrumbs_enabled = not breadcrumbs_enabled

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if breadcrumbs_enabled then
			dropbar_utils.bar.attach(vim.api.nvim_win_get_buf(win), win)
		elseif vim.wo[win].winbar == "%{%v:lua.dropbar()%}" then
			vim.wo[win].winbar = ""
		end
	end

	vim.notify("Breadcrumbs " .. (breadcrumbs_enabled and "enabled" or "disabled"))
end

vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Pick Symbols in Winbar" })
vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to Start of Current Context" })
vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select Next Context" })
vim.keymap.set("n", "<leader>tb", toggle_breadcrumbs, { desc = "Toggle Breadcrumbs" })
