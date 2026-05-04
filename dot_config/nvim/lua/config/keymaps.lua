local set = vim.keymap.set

set("n", "K", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_hover, 0) then
      return vim.lsp.buf.hover()
    end
  end

  vim.notify("No LSP hover available for this buffer", vim.log.levels.INFO, { title = "LSP" })
end, { desc = "Hover" })

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
