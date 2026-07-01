require("diffview").setup()

local map = vim.keymap.set

map("n", "<leader>Gv", "<cmd>DiffviewOpen<cr>", { desc = "Git Diffview Open" })
map("n", "<leader>GV", "<cmd>DiffviewClose<cr>", { desc = "Git Diffview Close" })
map("n", "<leader>Gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git File History (Buffer)" })
