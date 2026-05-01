require("tiny-code-action").setup({
	picker = "fzf-lua",
})

vim.keymap.set({ "n", "x" }, "<leader>ca", function()
	require("tiny-code-action").code_action()
end, { desc = "Code Action" })

vim.keymap.set({ "n", "x" }, "gra", function()
	require("tiny-code-action").code_action()
end, { desc = "Code Action" })
