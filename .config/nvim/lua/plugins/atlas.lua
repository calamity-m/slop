local atlas_opts = {
	pulls = {
		providers = {
			github = {
				cache_ttl = 300,
				views = {
					{
						name = "Mine",
						key = "1",
						layout = "plain",
						search = "author:@me sort:updated-desc",
					},
					{
						name = "Reviewing",
						key = "2",
						layout = "plain",
						search = "review-requested:@me sort:updated-desc",
					},
					{
						name = "Assigned",
						key = "3",
						layout = "plain",
						search = "assignee:@me sort:updated-desc",
					},
				},
			},
			gitlab = {
				base_url = os.getenv("GITLAB_URL") or "https://gitlab.com",
				token = os.getenv("GITLAB_TOKEN") or "",
				cache_ttl = 300,
				views = {
					{
						name = "Assigned",
						key = "1",
						scope = "assigned_to_me",
					},
					{
						name = "Reviewing",
						key = "2",
						scope = "all",
						extra_params = { reviewer_id = "Me" },
					},
					{
						name = "Created",
						key = "3",
						scope = "created_by_me",
					},
				},
			},
		},
	},
	issues = {
		providers = {
			github = {
				cache_ttl = 300,
				views = {
					{
						name = "Assigned",
						key = "1",
						layout = "plain",
						search = "assignee:@me is:open",
					},
					{
						name = "Created",
						key = "2",
						layout = "plain",
						search = "author:@me is:open",
					},
					{
						name = "Mentions",
						key = "3",
						layout = "plain",
						search = "mentions:@me is:open",
					},
				},
			},
			gitlab = {
				base_url = os.getenv("GITLAB_URL") or "https://gitlab.com",
				token = os.getenv("GITLAB_TOKEN") or "",
				cache_ttl = 300,
				views = {
					{
						name = "Assigned",
						key = "1",
						scope = "assigned_to_me",
						state = "opened",
					},
					{
						name = "Created",
						key = "2",
						scope = "created_by_me",
						state = "opened",
					},
					{
						name = "All open",
						key = "3",
						scope = "all",
						state = "opened",
					},
				},
			},
		},
	},
}

pcall(function()
	local local_opts = require("local.atlas")
	if type(local_opts) == "function" then
		atlas_opts = local_opts(atlas_opts) or atlas_opts
	else
		atlas_opts = vim.tbl_deep_extend("force", atlas_opts, local_opts)
	end
end)

require("atlas").setup(atlas_opts)

local map = vim.keymap.set

map("n", "<leader>aap", "<cmd>AtlasPulls github<cr>", { desc = "Atlas GitHub Pulls" })
map("n", "<leader>aai", "<cmd>AtlasIssues github<cr>", { desc = "Atlas GitHub Issues" })
map("n", "<leader>aas", "<cmd>AtlasSearch github<cr>", { desc = "Atlas GitHub Search" })

map("n", "<leader>agp", "<cmd>AtlasPulls gitlab<cr>", { desc = "Atlas GitLab Pulls" })
map("n", "<leader>agi", "<cmd>AtlasIssues gitlab<cr>", { desc = "Atlas GitLab Issues" })
map("n", "<leader>ags", "<cmd>AtlasSearch gitlab<cr>", { desc = "Atlas GitLab Search" })

map("n", "<leader>al", "<cmd>AtlasLogs<cr>", { desc = "Atlas Logs" })
