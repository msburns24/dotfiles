-- More Information:
-- https://nvchad.com/docs/config/lsp
--
-- Available LSP Servers: 
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md


require("nvchad.configs.lspconfig").defaults()

local servers = {
  -- Defaults
  "html", "cssls",

  -- Custom
  "pyright",
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
