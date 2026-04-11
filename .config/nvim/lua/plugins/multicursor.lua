local mc = require("multicursor-nvim")
local map = vim.keymap.set

mc.setup()

map({ "n", "x" }, "<C-up>", function()
	mc.lineAddCursor(-1)
end, { desc = "Add Cursor Above" })

map({ "n", "x" }, "<C-down>", function()
	mc.lineAddCursor(1)
end, { desc = "Add Cursor Below" })

map({ "n", "x" }, "<leader><up>", function()
	mc.lineSkipCursor(-1)
end, { desc = "Skip Cursor Above" })

map({ "n", "x" }, "<leader><down>", function()
	mc.lineSkipCursor(1)
end, { desc = "Skip Cursor Below" })

map({ "n", "x" }, "<leader>mn", function()
	mc.matchAddCursor(1)
end, { desc = "Add Cursor at Next Match" })

map({ "n", "x" }, "<leader>ms", function()
	mc.matchSkipCursor(1)
end, { desc = "Skip Next Match" })

map({ "n", "x" }, "<leader>mN", function()
	mc.matchAddCursor(-1)
end, { desc = "Add Cursor at Previous Match" })

map({ "n", "x" }, "<leader>mS", function()
	mc.matchSkipCursor(-1)
end, { desc = "Skip Previous Match" })

map("n", "<c-leftmouse>", mc.handleMouse, { desc = "Toggle Cursor with Mouse" })
map("n", "<c-leftdrag>", mc.handleMouseDrag, { desc = "Drag Cursor Selection" })
map("n", "<c-leftrelease>", mc.handleMouseRelease, { desc = "Release Cursor Selection" })
map({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "Toggle Cursors" })

mc.addKeymapLayer(function(layer_set)
	layer_set({ "n", "x" }, "<left>", mc.prevCursor)
	layer_set({ "n", "x" }, "<right>", mc.nextCursor)
	layer_set({ "n", "x" }, "<leader>x", mc.deleteCursor)

	layer_set("n", "<esc>", function()
		if not mc.cursorsEnabled() then
			mc.enableCursors()
		else
			mc.clearCursors()
		end
	end)
end)
