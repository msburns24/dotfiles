# Neovim Config

## Structure

```
󰉋 ~/AppData/Local/nvim/
├─ 󰉋 lua/                         ← Lua configuration modules
│  ├─ 󰉋 configs/                  ← Plugin-specific configuration files
│  │  ├─ 󰢱 conform.lua            ← Code formatter settings
│  │  ├─ 󰢱 lazy.lua               ← Lazy plugin manager options
│  │  ├─ 󰢱 lspconfig.lua          ← LSP server setup
│  │  ├─ 󰢱 nvim-tree.lua          ← File explorer settings
│  │  ├─ 󰢱 render-markdown.lua    ← Markdown rendering options
│  │  └─ 󰢱 treesitter.lua         ← Treesitter parsers and highlighting
│  │
│  ├─ 󰉋 plugins/                  ← Plugin list loaded by Lazy
│  │  └─ 󰢱 init.lua
│  │
│  ├─ 󰉋 snippets/                 ← Custom snippet files
│  │  └─ 󰘦 python.json
│  │
│  ├─ 󰢱 autocmds.lua              ← Automations for events (e.g., opening file)
│  ├─ 󰢱 chadrc.lua                ← NvChad theme and UI customization
│  ├─ 󰢱 mappings.lua              ← Key mappings
│  └─ 󰢱 options.lua               ← Core editor behavior/appearance
│
├─  .stylua.toml
├─ 󰢱 init.lua                     ← Entry point for configuration
├─ 󰘦 lazy-lock.json               ← Lockfile pinning installed plugin versions
└─ 󰋼 README.md
```
