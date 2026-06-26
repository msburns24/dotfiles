--[[

  ┌─────────────────────────────────────────────────────────────────────────┐
  │                                                                         │
  │                          Options Configuration                          │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘

  Purpose

      Defines options that control editor core behavior/appearance (e.g., UI
      preferences, mechanics, behaviors, etc.)

  Overview

      1. Basic Configuration
      2. Tab Sizes
      3. Appearance
      4. Plugins (cmp, nvim-tree)

  Config File References

      - nvchad.options

]]


---- Basic Configuration -------------------------------------------------------

require "nvchad.options"
local o = vim.o


o.shell = "powershell"    -- Use PowerShell instead of Command Prompt
o.expandtab = true        -- Use spaces when inserting a tab
o.smartindent = true      -- Maintain indent when starting new line


-- Use absolute line numbers, not relative
o.number = true
o.relativenumber = false



---- Tab Sizes -----------------------------------------------------------------

-- Smart Tab Size
function SetTabSize(size)
  -- Usage:
  -- `:lua SetTabSize(n)`
  vim.o.tabstop = size       -- Number of spaces <Tab> counts for
  vim.o.softtabstop = size   -- Number of spaces <Tab> counts for when editing
  vim.o.shiftwidth = size    -- Number of spaces for autoindent
end

local tabsize = 2   -- Default
if (vim.bo.filetype == 'python') then
    tabsize = 4
end
SetTabSize(tabsize)



---- Appearance ----------------------------------------------------------------

-- Highlight / Search ('/')
o.incsearch = true        -- Start highlighting search while typing
o.hlsearch = false        -- Stop highlighting after pressing <CR>
o.cursorlineopt ='both'   -- Enables cursor line
o.colorcolumn = "80"      -- Add column at 80 characters to limit length
o.scrolloff = 8           -- Keep 8 lines at top/bottom when Scrolling
o.signcolumn = "yes"      -- When and how to draw the signcolumn.


-- Whitespace characters
o.list = true             -- Show whitespace characters
vim.opt.listchars = {     -- Strings to use when showing whitespace
  tab = '» ',
  trail = '·',
  nbsp = '␣'
}



---- Plugins -------------------------------------------------------------------

--[[

                               Note (11/30/2025)

  The purpose of this section is to (1) create functions to toggle the 
  autocompletions, and (2) disable autocompletions for text-based files like
  `.txt`, `.md`, etc.

  I had previously disabled this part of the script when I went through to
  eliminate much of the eager loading in favor of lazy-loading. This was done
  to help improve Neovim startup time, since the work PC's load time was
  massive compared to my home PC.

  However, I noticed that the cmp is exceptionally disruptive, attempting to
  provide suggestions for every single word that is typed. It also leads to
  accidental accepting of suggestions, leading to misspelled words. This is
  most frequently seen when adjusting line length to fit under 80 characters.

  I'm turning this back on to see if it works alright when having this part
  of the script load eagerly. If it starts to have a significant impact on the
  Neovim load time, I can look at restructuring this section to still disable
  cmp on text-based files, but done in a lazier way.

]]


local cmp = require('cmp')


function enable_cmp()
  -- :lua enable_cmp()
  cmp.setup({ enabled = true })
end


function disable_cmp()
  -- :lua disable_cmp()
  cmp.setup({ enabled = false })
end


cmp.setup({
  enabled = function()
    -- Disable CMP if file type is tex, markdown, or unknown
    local disabled = false

    disabled = disabled or (vim.bo.filetype == 'text')
    disabled = disabled or (vim.bo.filetype == 'markdown')
    return not disabled
  end,
})


-- nvim-tree
local nvim_tree = require('nvim-tree')
local nvim_tree_config = require('configs.nvim-tree')
nvim_tree.setup(nvim_tree_config)

