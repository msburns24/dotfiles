-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },

    ["@markup.italic"] = {
      fg = '#f9e2af',
      italic = true,
    },

    ["@markup.strong"] = {
      fg = '#cba6f7',
      bold = true,
    },

    -- Markdown heading levels — Catppuccin Mocha accent colors (Red → Peach → Yellow → Green → Teal → Blue)
    ["RenderMarkdownH1"] = { fg = '#f38ba8', bold = true },
    ["RenderMarkdownH2"] = { fg = '#fab387', bold = true },
    ["RenderMarkdownH3"] = { fg = '#f9e2af', bold = true },
    ["RenderMarkdownH4"] = { fg = '#a6e3a1', bold = true },
    ["RenderMarkdownH5"] = { fg = '#94e2d5', bold = true },
    ["RenderMarkdownH6"] = { fg = '#89b4fa', bold = true },

    -- ["@text.title.{2}.markdown"] = {
    --   fg = '#ff0000',
    --   bold = true,
    -- },

    --[[

      Notes 12/27/2025

      I noticed that the `["@markup.strong"]` had an effect, but ChatGPT said
      to include the below as well. Leaving it commented out, but try
      un-commenting it if something is going wrong.

    --]]

    -- markdownBold = {
    --   fg = '#ffff00',
    --   bold = true,
    -- },
    --
    -- markdownBoldDelimiter = {
    --   fg = '##00ff00',
    -- }
},
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}

M.term =    {
 base46_colors = true,
 winopts = { number = false },
 sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
 float = {
   relative = "editor",
   row = 0.15,   -- I think this is % position vertical?
   col = 0.15,   -- And this is % position horizontal?
   -- width = 0.5,
   -- height = 0.4,
   height = 0.6,
   width = 0.7,
   border = "single",
 },
}


return M
