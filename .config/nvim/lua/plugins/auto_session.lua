require("auto-session").setup({
	suppressed_dirs = { "~/", "~/Downloads", "/" },
})

local map = vim.keymap.set
local prefix = "<leader>vs"

map("n", prefix .. "s", "<cmd>AutoSession save<CR>", { desc = "Save Session" })
map("n", prefix .. "r", "<cmd>AutoSession restore<CR>", { desc = "Restore Session" })
map("n", "<leader>fs", "<cmd>AutoSession search<CR>", { desc = "Find Sessions" })
map("n", prefix .. "d", "<cmd>AutoSession deletePicker<CR>", { desc = "Delete Session" })
map("n", prefix .. "t", "<cmd>AutoSession toggle<CR>", { desc = "Toggle Session Autosave" })
