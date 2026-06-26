return {
  {
    "stevearc/conform.nvim",

    -- event = 'BufWritePre', -- uncomment for format on save
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
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = function()
      return require "configs.render-markdown"
    end,
  },

  {
    -- Provides syntax highlighting for code
    "nvim-treesitter/nvim-treesitter",

    branch = "master",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",

    opts = function()
      return require "configs.treesitter"
    end,

    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
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
