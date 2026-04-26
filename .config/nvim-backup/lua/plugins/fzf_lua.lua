local fzf = require("fzf-lua")
local map = vim.keymap.set
local theme_picker = require("custom.theme_picker")
local work_global = require("custom.fzf_work_global")

fzf.setup({
	"fzf-native",
	winopts = {
		height = 0.85,
		width = 0.80,
		row = 0.35,
		col = 0.50,
		border = "rounded",
		preview = {
			layout = "flex",
			flip_columns = 120,
			scrollbar = "float",
		},
	},
	keymap = {
		fzf = {
			["ctrl-q"] = "select-all+accept",
		},
	},
	grep = {
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/' --max-columns=4096 -e",
	},
	work_global_grep = {
		profile = 0,
		fzf_opts = {},
	},
	haunt_global = {
		profile = 0,
		fzf_opts = {
			["--delimiter"] = "[:]",
			["--with-nth"] = "1..",
		},
	},
})

-- Route vim.ui.select through fzf-lua globally. Affects LSP code actions,
-- :YankyRingHistory, and any other plugin that calls vim.ui.select.
fzf.register_ui_select()

local function git_global()
	fzf.fzf_exec(function(fzf_cb)
		fzf_cb()
	end, {
		prompt = "Git [@ stash | # commits | ! branches | ? status]> ",
		actions = {
			["default"] = function(_, opts)
				local query = opts.__call_opts.query or ""

				if query == "" or query:match("^%s*$") then
					fzf.git_files()
				elseif query:sub(1, 1) == "@" then
					fzf.git_stash()
				elseif query:sub(1, 1) == "#" then
					fzf.git_commits()
				elseif query:sub(1, 1) == "!" then
					fzf.git_branches()
				elseif query:sub(1, 1) == "?" then
					fzf.git_status()
				else
					fzf.git_files({ query = query })
				end
			end,
		},
	})
end

map("n", "F", work_global.open, { desc = "Fzf Global" })
map("n", "<leader>ff", fzf.global, { desc = "Fzf Global" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Live Grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fh", fzf.help_tags, { desc = "Help Tags" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume Last Picker" })
map("n", "<leader>fo", fzf.oldfiles, { desc = "Recent Files" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Document Diagnostics" })
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document Symbols" })
map("n", "<leader>fG", git_global, { desc = "Git Global Picker" })
map("n", "<leader>ft", theme_picker.pick, { desc = "Themes" })

map("n", "<leader>gr", fzf.lsp_references, { desc = "References" })
map("n", "<leader>gi", fzf.lsp_implementations, { desc = "Implementations" })
map("n", "<leader>gt", fzf.lsp_typedefs, { desc = "Type Definitions" })
