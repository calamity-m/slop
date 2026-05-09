local gitsigns = require("gitsigns")

local function set_word_diff_hls()
	vim.api.nvim_set_hl(0, "GitSignsAddLnInline", { bg = "#3a6b3a", bold = true })
	vim.api.nvim_set_hl(0, "GitSignsChangeLnInline", { bg = "#3a3a1e", bold = true })
	vim.api.nvim_set_hl(0, "GitSignsDeleteLnInline", { bg = "#4a1e1e", bold = true })
end

set_word_diff_hls()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_word_diff_hls })

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

		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "Git Next Hunk" })

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "Git Previous Hunk" })

		map("n", "<leader>Gs", gitsigns.stage_hunk, { desc = "Git Stage Hunk" })
		map("n", "<leader>Gr", gitsigns.reset_hunk, { desc = "Git Reset Hunk" })

		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Git Stage Selection" })

		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Git Reset Selection" })

		map("n", "<leader>GS", gitsigns.stage_buffer, { desc = "Git Stage Buffer" })
		map("n", "<leader>GR", gitsigns.reset_buffer, { desc = "Git Reset Buffer" })
		map("n", "<leader>Gp", gitsigns.preview_hunk, { desc = "Git Preview Hunk" })
		map("n", "<leader>Gi", gitsigns.preview_hunk_inline, { desc = "Git Preview Hunk Inline" })

		map("n", "<leader>Gb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "Git Blame Line" })

		map("n", "<leader>Gd", gitsigns.diffthis, { desc = "Git Diff This" })

		map("n", "<leader>GD", function()
			gitsigns.diffthis("~")
		end, { desc = "Git Diff This ~" })

		map("n", "<leader>GQ", function()
			gitsigns.setqflist("all", { open = false })
			vim.schedule(function()
				require("fzf-lua").quickfix()
			end)
		end, { desc = "Git Hunks to Quickfix (All)" })
		map("n", "<leader>hq", function()
			gitsigns.setqflist(nil, { open = false })
			vim.schedule(function()
				require("fzf-lua").quickfix()
			end)
		end, { desc = "Git Hunks to Quickfix" })

		map("n", "<leader>Gtb", gitsigns.toggle_current_line_blame, { desc = "Git Toggle Line Blame" })
		map("n", "<leader>Gtw", gitsigns.toggle_word_diff, { desc = "Git Toggle Word Diff" })
		map("n", "<leader>Gtd", gitsigns.toggle_deleted, { desc = "Git Toggle Deleted (Buffer)" })
	end,
})
