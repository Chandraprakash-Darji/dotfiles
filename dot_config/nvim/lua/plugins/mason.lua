-- Filename: ~/github/dotfiles-latest/neovim/nvim-lazyvim/lua/plugins/mason-nvim.lua

-- https://github.com/mason-org/mason.nvim
-- https://github.com/jonschlinkert/markdown-toc
return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    -- marksman and markdownlint come by default in the lazyvim config
    vim.list_extend(opts.ensure_installed, { "markdownlint", "marksman", "markdown-toc" })
  end,
}
