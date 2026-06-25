local M = {}

local function pane_name()
	local cwd = vim.uv.cwd() or vim.fn.getcwd()
	local directory = vim.fn.fnamemodify(cwd, ":t")
	local buffer = vim.api.nvim_buf_get_name(0)
	local buffername = buffer ~= "" and vim.fn.fnamemodify(buffer, ":t") or "[No Name]"

	return string.format("nvim - %s - %s", directory, buffername)
end

function M.rename_pane()
	if not vim.env.ZELLIJ or vim.fn.executable("zellij") ~= 1 then
		return
	end

	local pane_id = vim.env.ZELLIJ_PANE_ID
	if not pane_id or pane_id == "" then
		return
	end

	-- Target this Neovim pane explicitly; detached actions otherwise rename whichever
	-- pane Zellij considers focused when the command is processed.
	vim.system({ "zellij", "action", "rename-pane", "--pane-id", pane_id, pane_name() }, { detach = true })
end

function M.setup()
	vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "DirChanged" }, {
		group = vim.api.nvim_create_augroup("ZellijPaneName", { clear = true }),
		callback = M.rename_pane,
	})
end

return M
