local set = vim.keymap.set

set("n", "<leader>rr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "replace" })
set("n", "<S-x>", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })

set("n", "<leader>rt", function()
  vim.cmd("ReferencerToggle")
end, { desc = "Toggle Referencer" })

set("n", "<leader>ru", function()
  vim.cmd("ReferencerUpdate")
end, { desc = "Update Referencer" })
