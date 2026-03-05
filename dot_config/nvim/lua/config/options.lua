local opt = vim.opt
local g = vim.g

opt.cursorline = false
opt.sidescrolloff = 16
opt.scrolloff = 8
opt.backupcopy = "yes" -- for  bun --hot/watch to work properly

g.neovide_opacity = 0.98
g.neovide_hide_mouse_when_typing = true
g.neovide_cursor_trail_size = 0.8
g.neovide_cursor_vfx_mode = "pixiedust"

if g.neovide then
  g.is_neovide = true
else
  g.is_neovide = false
end
