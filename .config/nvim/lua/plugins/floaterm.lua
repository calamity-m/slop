-- Normal mode
vim.keymap.set("n", "<C-\\>", "<cmd>FloatermToggle<CR>", { desc = "Toggle Floaterm" })

-- Terminal mode (escape + toggle)
vim.keymap.set("t", "<C-\\>", [[<C-\><C-n><cmd>FloatermToggle<CR>]], {
	desc = "Toggle Floaterm",
})
