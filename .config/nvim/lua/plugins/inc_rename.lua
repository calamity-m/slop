require("inc_rename").setup()

vim.keymap.set("n", "<leader>cr", function()
	return ":IncRename " .. vim.fn.expand("<cword>")
end, { desc = "Rename", expr = true })
