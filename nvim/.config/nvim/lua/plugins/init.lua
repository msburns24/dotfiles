return {
  {
    "stevearc/conform.nvim",

    event = "BufWritePre", -- format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",

    config = function()
      require "configs.lspconfig"
    end,
  },


  -- Configure Snippets
  {
    "L3MON4D3/LuaSnip",

    event = "VeryLazy",

    config = function()
      -- Load directly from plugin (rafamadriz/friendly-snippets)
      require("luasnip.loaders.from_vscode").lazy_load()
      -- Load from file
      -- require("luasnip.loaders.from_vscode").load({paths = "./snippets"})
    end
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      return require "configs.render-markdown"
    end,
  },

  -- nvim-treesitter was archived (2026-04-03) and its frozen `master` branch
  -- crashes on Neovim 0.12's list-valued query captures. We disable it (this
  -- also neutralizes NvChad's dead `nvim-treesitter.configs.setup()` spec) and
  -- drive highlight/indent/fold from native Neovim treesitter instead.
  { "nvim-treesitter/nvim-treesitter", enabled = false },

  {
    -- Parser installer for non-bundled languages (native highlighting is enabled
    -- via the FileType autocmd in lua/autocmds.lua, so highlight is left off here).
    "romus204/tree-sitter-manager.nvim",
    lazy = false,
    opts = {
      ensure_installed = { "python" }, -- non-bundled langs only; NOT markdown
      highlight = false,
      auto_install = false,
    },
    config = function(_, opts)
      require("tree-sitter-manager").setup(opts)
    end,
  },

  -- {
  --   -- Smart code folding
  --   "kevinhwang91/nvim-ufo",
  --   dependencies = "kevinhwang91/promise-async",
  -- },


  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = {
  --     ensure_installed = {
  --       "vim", "lua", "vimdoc",
  --      "html", "css"
  --     },
  --   },
  -- },
}
