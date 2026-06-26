--[[

  ┌─────────────────────────────────────────────────────────────────────────┐
  │                                                                         │
  │                                 Mappings                                │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘

  Purpose

      Contains key mappings that define how key combinations are translated
      into editor commands or Lua functions.

      Can help to optimze workflows, reduce repetitive actions, etc.

]]


require "nvchad.mappings"
local map = vim.keymap.set


-- Exit insert mode with "jk"
map("i", "jk", "<ESC>")


-- Exiting terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })


-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

