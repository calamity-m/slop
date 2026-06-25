local map = vim.keymap.set

-- General neovim keymaps
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
local function delete_buffers(except_current, force)
  local current = vim.api.nvim_get_current_buf()
  local buffers = {}
  local skipped = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local should_delete = vim.api.nvim_buf_is_loaded(buf) and not (except_current and buf == current)
    if should_delete and (force or vim.bo[buf].buflisted) then
      if vim.bo[buf].buftype == "terminal" and not force then
        skipped = skipped + 1
      elseif buf == current then
        table.insert(buffers, buf)
      else
        table.insert(buffers, 1, buf)
      end
    end
  end

  for _, buf in ipairs(buffers) do
    local ok = pcall(vim.api.nvim_buf_delete, buf, { force = force })
    if not ok then
      skipped = skipped + 1
    end
  end

  if skipped > 0 then
    vim.notify("Skipped " .. skipped .. " protected buffer(s)", vim.log.levels.INFO)
  end
end

map("n", "<leader>bdd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })
map("n", "<leader>bda", function()
  delete_buffers(false, false)
end, { desc = "Delete All Buffers" })
map("n", "<leader>bdo", function()
  delete_buffers(true, false)
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bdA", function()
  delete_buffers(false, true)
end, { desc = "Force Delete All Buffers" })
map("n", "<leader>bdO", function()
  delete_buffers(true, true)
end, { desc = "Force Delete Other Buffers" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

map("n", "<leader>vpu", function()
  vim.pack.update()
end, { desc = "Update Plugins" })

map("n", "<leader>vpl", function()
  vim.pack.update(nil, { offline = true })
end, { desc = "List Plugins" })

map("n", "<leader>vpd", function()
  local inactive = vim.iter(vim.pack.get())
    :filter(function(plugin)
      return not plugin.active
    end)
    :map(function(plugin)
      return plugin.spec.name
    end)
    :totable()

  if #inactive == 0 then
    vim.notify("No inactive plugins to delete", vim.log.levels.INFO)
    return
  end

  vim.ui.select({ "Delete", "Cancel" }, {
    prompt = "Delete inactive plugins: " .. table.concat(inactive, ", ") .. "?",
  }, function(choice)
    if choice == "Delete" then
      vim.pack.del(inactive)
    end
  end)
end, { desc = "Delete Inactive Plugins" })

-- Folds
map("n", "<leader>z", "za", { desc = "Toggle Fold" })
map("n", "<leader>Z", "zA", { desc = "Toggle Fold Recursive" })
map("n", "zR", "zR", { desc = "Open All Folds" })
map("n", "zM", "zM", { desc = "Close All Folds" })

-- Blackhole registers, delete without affecting copy buffer
map("v", "<leader>dd", '"_d', { desc = "Delete Without Yank" })
map("v", "<leader>dc", '"_c', { desc = "Change Without Yank" })
map("n", "x", '"_x', { desc = "Delete Char Without Yank" })
map("v", "p", '"_dP', { desc = "Paste Without Yank Replace" })
