local fzf = require("fzf-lua")

local file_picker_opts = {
	hidden = true,
	fd_opts = "--color=never --type f --type l --hidden --exclude .git --exclude .jj",
	rg_opts = "--color=never --files --hidden --glob '!.git/**' --glob '!.jj/**'",
}

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
	files = file_picker_opts,
	global = file_picker_opts,
	grep = {
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/**' --max-columns=4096 -e",
	},
})

fzf.register_ui_select()

local function git_worktrees()
	local lines = vim.fn.systemlist({ "git", "worktree", "list", "--porcelain" })
	if vim.v.shell_error ~= 0 or #lines == 0 then
		vim.notify("Not a git repository or no worktrees found", vim.log.levels.ERROR)
		return
	end

	local entries = {}
	local paths = {}
	local current = nil

	local function add_current()
		if not current or not current.path then
			return
		end

		local label = current.path
		if current.branch then
			label = label .. " " .. current.branch
		elseif current.detached then
			label = label .. " (detached)"
		end

		table.insert(entries, label)
		paths[label] = current.path
	end

	for _, line in ipairs(lines) do
		if line == "" then
			add_current()
			current = nil
		else
			local key, value = line:match("^(%S+)%s*(.*)$")
			if key == "worktree" then
				current = { path = value }
			elseif current and key == "branch" then
				current.branch = value:gsub("^refs/heads/", "")
			elseif current and key == "detached" then
				current.detached = true
			end
		end
	end
	add_current()

	if #entries == 0 then
		vim.notify("No git worktrees found", vim.log.levels.ERROR)
		return
	end

	fzf.fzf_exec(entries, {
		prompt = "Git Worktrees> ",
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				local path = paths[selected[1]]
				if not path then
					return
				end

				vim.cmd.cd(vim.fn.fnameescape(path))
				vim.notify("Changed directory to: " .. path, vim.log.levels.INFO)
				fzf.files()
			end,
		},
	})
end

vim.api.nvim_create_user_command("GitWorktrees", git_worktrees, {})

local map = vim.keymap.set

map("n", "F", fzf.global, { desc = "Fzf Global" })
map("n", "<leader>ff", fzf.global, { desc = "Fzf Global" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Live Grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fW", git_worktrees, { desc = "Git Worktrees" })

map("n", "<leader>cD", fzf.diagnostics_document, { desc = "Document Diagnostics" })
map("n", "<leader>cs", fzf.lsp_document_symbols, { desc = "Document Symbols" })

map("n", "gri", fzf.lsp_implementations, { desc = "Goto Implementation" })
map("n", "grr", fzf.lsp_references, { desc = "Goto References" })
map("n", "grt", fzf.lsp_typedefs, { desc = "Goto Type Definition" })
map("n", "gO", fzf.lsp_document_symbols, { desc = "Document Symbols" })

map("n", "<leader>gr", fzf.lsp_references, { desc = "References" })
map("n", "<leader>gi", fzf.lsp_implementations, { desc = "Implementations" })
map("n", "<leader>gt", fzf.lsp_typedefs, { desc = "Type Definitions" })
