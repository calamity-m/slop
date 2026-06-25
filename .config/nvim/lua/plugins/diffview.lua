local diffview = require("diffview")

diffview.setup({
	enhanced_diff_hl = true,
	use_icons = true,
	view = {
		default = { layout = "diff2_horizontal" },
	},
	file_panel = {
		listing_style = "tree",
		win_config = { position = "left", width = 35 },
	},
})

local map = vim.keymap.set

-- Merge/rebase conflict resolution is handled by diffview's built-in, buffer-local
-- keymaps in the 3-way merge tool (opened automatically by DiffviewOpen during a
-- conflict): ]x/[x to navigate, <leader>c{o,t,b,a}/dx per-hunk, capitalized for
-- the whole file. Intentionally not rebound here to avoid drifting from upstream
-- defaults and shadowing the global <leader>c ("Code") group, which these only
-- override inside merge buffers.
map("n", "<leader>Gvv", "<cmd>DiffviewOpen<cr>", { desc = "Diffview Open" })
map("n", "<leader>Gvc", "<cmd>DiffviewClose<cr>", { desc = "Diffview Close" })
map("n", "<leader>Gvr", "<cmd>DiffviewRefresh<cr>", { desc = "Diffview Refresh" })
map("n", "<leader>Gvh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview File History (Current)" })
map("n", "<leader>GvH", "<cmd>DiffviewFileHistory<cr>", { desc = "Diffview File History (Project)" })

-- Visual-mode history is scoped to the selected line range.
map("v", "<leader>Gvh", "<Esc><cmd>'<,'>DiffviewFileHistory<cr>", { desc = "Diffview File History (Selection)" })
