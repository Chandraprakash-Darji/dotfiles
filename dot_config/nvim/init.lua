-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- Setup lazy.nvim
require("lazy").setup({
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
        },
      })

      -- File search: Cmd+P or <leader>ff
      vim.keymap.set("n", "<D-p>", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })

      -- Command palette: Cmd+Shift+P or <leader>fc
      vim.keymap.set("n", "<D-S-p>", builtin.commands, { desc = "Command palette" })
      vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Command palette" })
    end,
  },
}, {
  ui = { border = "rounded" },
})
