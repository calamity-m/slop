local map = vim.keymap.set
local lint = require("lint")

lint.linters_by_ft = {
	go = { "golangcilint" },
	rust = { "clippy" },
	python = { "ruff" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	proto = { "buf_lint" },
	javascript = { "oxlint" },
	javascriptreact = { "oxlint" },
	typescript = { "oxlint" },
	typescriptreact = { "oxlint" },
	vue = { "oxlint" },
}

map("n", "<leader>cl", function()
	lint.try_lint()
end, { desc = "Run Lint" })
