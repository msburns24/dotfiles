--[[

  ┌─────────────────────────────────────────────────────────────────────────┐
  │                                                                         │
  │                          Neovim Configuration                           │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘

  Purpose

      This is the entry point for configuring Neovim. The rest of the
      config files flow from here.

  Overview

      1. Initial Config (theme manager, leader definition)
      2. Setup Lazy Plugin Manager
      3. Load Plugins
      4. Import Other Config Files
      5. Schedule Post-Init Configuations

  Config File References

      - configs.lazy
      - options
      - autocmds
      - mappings (scheduled)

]]


---- Initial Config ------------------------------------------------------------

-- I think this is for themes?
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"

-- Leader for command palette
vim.g.mapleader = " "
vim.g.maplocalleader = " "



---- Setup Lazy Plugin Manager -------------------------------------------------

-- Get path to lazy
-- (e.g. '%LOCALAPPDATA%\nvim-data\lazy\lazy.nvim\')
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"


-- git clone if path does not exist
-- if not vim.uv.fs_stat(lazypath) then
if not (vim.uv and vim.uv.fs_stat(lazypath)) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system {
    "git", "clone",
    "--filter=blob:none",
    repo, 
    "--branch=stable", lazypath 
  }
end


-- Add '...\lazy.nvim\' to runtime path
vim.opt.rtp:prepend(lazypath)



---- Load Plugins --------------------------------------------------------------

local lazy_config = require "configs.lazy"


-- Use Lazy to setup plugins
require("lazy").setup(
  {
    {
      -- NvChad to include a lot of bundled plugins
      "NvChad/NvChad",
      lazy = false,
      branch = "v2.5",
      import = "nvchad.plugins",
    },

    -- Look in '%LOCALAPPDATA%\nvim\lua\plugins\' directory for imports
    { import = "plugins" },
  },
  lazy_config
)


-- load theme
-- NOTE: `syntax` and `treesitter` hold the base46 colors for @keyword/@variable/
-- @type/etc. NvChad normally loads them from its nvim-treesitter plugin config,
-- but we disable that plugin (see lua/plugins/init.lua), so we load them here.
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "syntax")
dofile(vim.g.base46_cache .. "treesitter")
dofile(vim.g.base46_cache .. "statusline")


-- Disabling, I think this will load automatically? I think putting it here
-- prevents lazy-loading.

-- -- Other plugin setup
-- local render_markdown_config = require "configs.render-markdown"
-- require('render-markdown').setup(render_markdown_config)



---- Import Other Config Files -------------------------------------------------

require "options"
require "autocmds"



---- Schedule Post-Init Configuations ------------------------------------------

vim.schedule(function()
  require "mappings"
end)

