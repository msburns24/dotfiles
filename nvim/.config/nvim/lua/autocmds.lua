--[[

  ┌─────────────────────────────────────────────────────────────────────────┐
  │                                                                         │
  │                               Autocommands                              │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘

  Purpose

      Defines commands that automatically execute in response to specific
      Neovim events (e.g., opening, saving, switch files, etc.)

]]



require "nvchad.autocmds"


-- Highlight when yanking (copying) text
-- Try it with `yap` in normal mode
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank',
                                      { clear = true }),

  callback = function()
    vim.highlight.on_yank()
  end,
})


vim.api.nvim_create_autocmd('FileType', {
  desc = 'Setup code folding with nvim-treesitter.',
  -- pattern = { 'python' },

  callback = function()
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldlevel = 99  -- Start with all folds open
    -- vim.opt.foldlevelstart = 99

    -- Saw this on a tutorial but it throws an error
    -- vim.wo[0][0].foldlevelstart = 99
  end
})



-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = { 'python', 'javascript', 'rust' },
--   callback = function()
--     -- Enable Tree-sitter-based folding
--     vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
--     vim.wo.foldmethod = 'expr'
--
--     -- Optional: configure fold behavior
--     vim.wo.foldlevel = 99  -- Start with all folds open
--     vim.wo.foldlevelstart = 99
--   end,
-- })
