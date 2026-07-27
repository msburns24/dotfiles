local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    markdown = { "prettier" },
  },

  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
}

return options
