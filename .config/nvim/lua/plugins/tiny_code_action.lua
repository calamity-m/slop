require("tiny-code-action").setup({
	picker = "fzf-lua",
})

-- Work around a tiny-code-action fzf-lua picker bug that clobbers lines when
-- applying jdtls "import" code actions. jdtls sends code actions lazily, so the
-- previewer resolves them once (correctly) and caches the result on the entry as
-- `_resolved_action`. The fzf-lua apply path drops that cache and re-resolves;
-- jdtls is not idempotent on codeAction/resolve, so the second edit carries stale
-- ranges that overwrite existing imports / the class definition instead of
-- inserting. The telescope picker forwards the cached action and is unaffected.
-- Forward the cache here so apply reuses the exact edit shown in the preview.
-- Upstream fix tracked in .pi/plans/debug/jdtls-import-clobber.md.
do
	local fzf = require("tiny-code-action.pickers.fzf-lua")
	-- get_ctx_extracted returns the selected entry wrapper; remember the latest so
	-- apply_action (which only receives entry.action) can reach its cached resolve.
	local last_ctx
	local orig_get_ctx = fzf.get_ctx_extracted
	fzf.get_ctx_extracted = function(...)
		last_ctx = orig_get_ctx(...)
		return last_ctx
	end

	local orig_apply = fzf.apply_action
	fzf.apply_action = function(action, client, context, bufnr, resolved_from_preview)
		if resolved_from_preview == nil and last_ctx and last_ctx.action == action then
			local cached = last_ctx._resolved_action
			-- Only reuse a fully resolved action; otherwise fall back to the normal
			-- single-resolve path, which is correct (the second resolve is the bug).
			if cached and (cached.edit or cached.command) then
				resolved_from_preview = cached
			end
		end
		return orig_apply(action, client, context, bufnr, resolved_from_preview)
	end
end

vim.keymap.set({ "n", "x" }, "<leader>ca", function()
	require("tiny-code-action").code_action()
end, { desc = "Code Action" })

vim.keymap.set({ "n", "x" }, "gra", function()
	require("tiny-code-action").code_action()
end, { desc = "Code Action" })
