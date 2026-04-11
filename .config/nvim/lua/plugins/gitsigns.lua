local gitsigns = require("gitsigns")

gitsigns.setup({
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 100,
	},
	word_diff = false,
	on_attach = function(bufnr)
		local function map(mode, lhs, rhs, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Git Toggle Line Blame" })
		map("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "Git Toggle Word Diff" })
	end,
})
