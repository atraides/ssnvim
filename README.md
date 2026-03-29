# ssnvim

A hand-crafted Neovim configuration built from a clean slate. No distribution black-boxes, no inherited opinions — every file is explicitly written and commented. Daily driver for a stack spanning Python, Go, bash/zsh, Kubernetes, Helm, and ArgoCD.

19 plugins. Fully portable. `git clone` + `nvim` bootstraps the entire environment on any machine.

---

## Prerequisites

| Requirement | Notes |
|---|---|
| **Neovim 0.11+** | Required — `vim.lsp.config()` is a 0.11-only native API |
| **Nerd Font** | Icons in lualine and dashboard (e.g. [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)) |
| **git** | lazy.nvim bootstraps itself by cloning via git |
| **lazygit** | Required for `<leader>gg` floating lazygit window |
| **kubectl** | Optional — K8s context shown in statusline; absent = no context displayed |
| **pyenv / poetry / uv** | Optional — Python venv auto-detection in pyright |

---

## Installation

> **Note:** If you already have a Neovim config at `~/.config/nvim`, back it up first:
> ```bash
> mv ~/.config/nvim ~/.config/nvim.bak
> ```

```bash
git clone https://github.com/<your-github-username>/ssnvim ~/.config/nvim
nvim
```

On first launch, lazy.nvim bootstraps itself, then installs all 19 plugins, then Mason installs all 13 language servers and tools. This takes approximately 2–5 minutes. Watch the progress in the lazy.nvim UI.

---

## First Launch

After installation completes:

1. **Authenticate Copilot** — required once for GitHub Copilot (enterprise OAuth):
   ```
   :Copilot auth
   ```

2. **Verify the install:**
   ```
   :checkhealth lazy       → plugin manager healthy
   :checkhealth mason      → all tools installed
   :Mason                  → all servers green
   :Lazy                   → no plugin errors
   :Copilot status         → authenticated
   ```

3. **Measure startup time** (goal: < 100ms):
   ```bash
   nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
   ```

---

## Keybinding Reference

Leader key: `<Space>`

### General

| Key | Mode | Description |
|-----|------|-------------|
| `<Esc>` | n | Clear search highlight |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | n | Move to left / lower / upper / right window |
| `<C-Up>` / `<C-Down>` | n | Increase / decrease window height |
| `<C-Left>` / `<C-Right>` | n | Decrease / increase window width |
| `[b` / `]b` | n | Previous / next buffer |
| `<C-d>` / `<C-u>` | n | Scroll down / up (cursor stays centred) |
| `[q` / `]q` | n | Previous / next quickfix item |
| `[d` / `]d` | n | Previous / next diagnostic |
| `<leader>e` | n | Show diagnostic float |
| `<leader>d` | n, v | Delete without yanking |
| `J` / `K` | v | Move selection down / up |
| `<` / `>` | v | Indent left / right (stay in visual) |
| `<leader>p` | x | Paste over selection without yanking it |

### File Navigation

| Key | Mode | Description |
|-----|------|-------------|
| `-` | n | Open parent directory (oil.nvim) |

### Find / Picker (`<leader>f`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Find buffers |
| `<leader>fh` | n | Find help |
| `<leader>fs` | n | Find LSP symbols |
| `<leader>fd` | n | Find diagnostics |

### Git (`<leader>g`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>gg` | n | Open lazygit (floating window) |
| `]h` / `[h` | n | Next / prev hunk |
| `<leader>gs` | n, v | Stage hunk (visual: stage selected lines only) |
| `<leader>gr` | n, v | Reset hunk (visual: reset selected lines only) |
| `<leader>gp` | n | Preview hunk inline |
| `<leader>gb` | n | Toggle current-line git blame |

### LSP (`<leader>l` — active when LSP is attached)

| Key | Mode | Description |
|-----|------|-------------|
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gI` | n | Go to implementation |
| `K` | n | Hover documentation |
| `gr` | n | Find references |
| `<leader>lr` | n | Rename symbol |
| `<leader>la` | n | Code action |
| `<leader>lf` | n | Format buffer via LSP |

### Code / Format (`<leader>c`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>cf` | n | Format buffer (conform.nvim) |

### Terminal (`<leader>t`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>tt` | n | Open floating terminal |

### Completion (insert mode)

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Navigate items down / up |
| `<Tab>` / `<S-Tab>` | Navigate items / jump snippet placeholders |
| `<CR>` | Accept selected item |
| `<C-e>` | Dismiss completion menu |
| `<C-Space>` | Force-trigger completion |

### Treesitter Incremental Selection

| Key | Mode | Description |
|-----|------|-------------|
| `<A-o>` | n, v | Start / expand node selection |
| `<A-i>` | v | Shrink node selection |

---

## Language Support

| Language | LSP | Formatter | Linter |
|---|---|---|---|
| Python | `pyright` | `ruff_format` | `ruff` |
| Go | `gopls` | `goimports` | `golangci-lint` |
| Bash / sh / zsh | `bash-language-server` | `shfmt` | `shellcheck` |
| YAML (non-Helm) | `yaml-language-server` + SchemaStore | LSP fallback | `yamllint` |
| Helm templates | `helm-ls` | LSP fallback | — |
| Lua | `lua-ls` | `stylua` | — |

> **Note:** `yamlls` is explicitly excluded from `ft=helm` buffers to prevent conflicts with `helm-ls`.

---

## Plugin List

| Plugin | Purpose |
|---|---|
| `lazy.nvim` | Plugin manager; lazy-loading; lockfile |
| `snacks.nvim` | Picker, dashboard, lazygit, terminal, indent guides, notifier |
| `blink.cmp` | Completion engine |
| `copilot.lua` | GitHub Copilot integration |
| `blink-copilot` | Copilot source for blink.cmp |
| `nvim-lspconfig` | LSP client configuration |
| `mason.nvim` | Automated language server installation |
| `mason-lspconfig.nvim` | Bridge between mason and nvim-lspconfig |
| `conform.nvim` | Format-on-save runner |
| `nvim-lint` | Async linting |
| `nvim-treesitter` | Syntax highlighting and incremental selection |
| `rose-pine/neovim` | Colorscheme (dawn = light, moon = dark) |
| `auto-dark-mode.nvim` | Switches rose-pine variant with macOS appearance |
| `lualine.nvim` | Statusline with K8s context component |
| `oil.nvim` | File manager (filesystem-as-buffer) |
| `gitsigns.nvim` | In-buffer git decorations and hunk operations |
| `which-key.nvim` | Keybinding discovery popup |
| `schemastore.nvim` | YAML schema catalog (K8s, Helm, ArgoCD CRDs) |
| `nvim-autopairs` | Auto-close brackets and quotes |
