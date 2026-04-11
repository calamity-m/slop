local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write File" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit Window" })

-- Window management

map("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

map("n", "<leader>bH", "<cmd>vertical resize -4<CR>", { desc = "Resize Window Left" })
map("n", "<leader>bL", "<cmd>vertical resize +4<CR>", { desc = "Resize Window Right" })
map("n", "<leader>bK", "<cmd>resize +2<CR>", { desc = "Resize Window Up" })
map("n", "<leader>bJ", "<cmd>resize -2<CR>", { desc = "Resize Window Down" })

-- Blackhole registers, delete without affecting copy buffer

map("v", "<leader>d", '"_d', { desc = "Delete Without Yank" })
map("v", "<leader>c", '"_c', { desc = "Change Without Yank" })
map("n", "x", '"_x', { desc = "Delete Char Without Yank" })
map("v", "p", '"_dP', { desc = "Paste Without Yank Replace" })
