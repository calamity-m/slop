local auto_session = require("auto-session")

auto_session.setup({
	suppressed_dirs = { "~/", "~/Downloads", "/" },
})

local map = vim.keymap.set
local prefix = "<leader>vs"

local function delete_all_sessions()
	vim.ui.select({ "Delete all sessions", "Cancel" }, {
		prompt = "Delete every saved session?",
	}, function(choice)
		if choice ~= "Delete all sessions" then
			return
		end

		local sessions = require("auto-session.lib").get_session_list(auto_session.get_root_dir())
		if vim.tbl_isempty(sessions) then
			vim.notify("No sessions to delete")
			return
		end

		local deleted = 0
		for _, session in ipairs(sessions) do
			if auto_session.delete_session_file(session.path, session.display_name) then
				deleted = deleted + 1
			end
		end

		vim.notify(string.format("Deleted %d session%s", deleted, deleted == 1 and "" or "s"))
	end)
end

map("n", prefix .. "s", "<cmd>AutoSession save<CR>", { desc = "Save Session" })
map("n", prefix .. "r", "<cmd>AutoSession restore<CR>", { desc = "Restore Session" })
map("n", "<leader>fs", "<cmd>AutoSession search<CR>", { desc = "Find Sessions" })
map("n", prefix .. "d", "<cmd>AutoSession deletePicker<CR>", { desc = "Delete Session" })
map("n", prefix .. "D", "<cmd>AutoSession delete<CR>", { desc = "Delete Current Session" })
map("n", prefix .. "a", delete_all_sessions, { desc = "Delete All Sessions" })
map("n", prefix .. "t", "<cmd>AutoSession toggle<CR>", { desc = "Toggle Session Autosave" })
