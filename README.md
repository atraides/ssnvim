# ssnvim

A hand-crafted Neovim configuration built from a clean slate. Every line is explicit, commented,
and intentionally chosen — no distribution black-boxes, no inherited opinions.

**Stack:** Python · Go · bash/zsh · Kubernetes · Helm · ArgoCD · GitHub Actions

---

## Prerequisites

| Tool | Notes |
|---|---|
| **Neovim 0.11+** | Required. 0.12 when stable. |
| **Git** | For cloning and lazy.nvim bootstrap. |
| **A Nerd Font** | Any variant — icons in lualine, oil, snacks. |
| **lazygit** | For `<leader>gg` lazygit float. |
| **ripgrep** | For `<leader>/` live grep. |
| **fd** | For `<leader>ff` file finder. |
| **Node.js** | Required by several Mason-installed LSP servers. |
| **Go** | If working with Go files. |
| **Python + pyenv/poetry/uv** | If working with Python files. |

All language servers and linting/formatting tools are installed automatically by Mason on first launch.

---

## Installation

```bash
# Back up any existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone into the Neovim config directory
git clone https://github.com/atraides/ssnvim ~/.config/nvim

# Launch Neovim — lazy.nvim bootstraps itself, then installs all plugins
nvim
```

On first launch, lazy.nvim will:

1. Clone itself into `~/.local/share/nvim/lazy/lazy.nvim`
2. Install all 29 plugin specs
3. Trigger Mason to install all language servers and tools (this takes a few minutes)

You can watch progress with `:Lazy` and `:Mason`.

---

## First Launch Checklist

**1. Wait for Mason to finish**

Open `:Mason` and wait for all servers to show a green checkmark. This only happens once.

**2. Authenticate GitHub Copilot**

```
:Copilot auth
```

Follow the device flow in your browser. Token is stored in `~/.config/github-copilot/` — never in this repo.

**3. Verify everything is healthy**

```
:checkhealth lazy      -- plugin manager
:checkhealth mason     -- all tools installed
:Lazy                  -- no errors
:Copilot status        -- authenticated
```

---

## Key Bindings

Leader key is `<Space>`. Press `<leader>` and pause to see all bindings via which-key.

### Navigation

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader><space>` | Smart find files |
| `<leader>/` | Live grep |
| `<leader>fb` | Open buffers |
| `<leader>fr` | Recent files |
| `<leader>fp` | Projects |
| `<leader>e` | File explorer (snacks) |
| `-` | Open parent directory (oil.nvim) |

### Git

| Key | Action |
|---|---|
| `<leader>gg` | Open lazygit float |
| `<leader>gd` | Diff: git status |
| `<leader>gv` | Diff: repo history |
| `<leader>gV` | Diff: current file history |
| `<leader>gc` | Diff: compare revisions (prompts) |
| `<leader>gB` | Open file on GitHub in browser |
| `<leader>gi` / `<leader>gI` | GitHub Issues (open / all) |
| `<leader>gp` / `<leader>gP` | GitHub Pull Requests (open / all) |
| `]h` / `[h` | Next / previous hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghb` | Blame line |

### LSP (active in buffers with LSP attached)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gI` | Go to implementation |
| `gr` | References |
| `K` | Hover docs |
| `<leader>lr` | Rename symbol |
| `<leader>la` | Code actions |
| `<leader>lf` | Format buffer (LSP) |

### Formatting

| Key | Action |
|---|---|
| `<leader>cf` | Format buffer (conform) |
| `<leader>uf` | Toggle autoformat on/off |

### Motion (flash.nvim)

| Key | Action |
|---|---|
| `m` | Flash jump (any visible location) |
| `M` | Flash treesitter (select by syntax node) |

### Editing

| Key | Action |
|---|---|
| `<space>m` | Toggle split/join block (treesj) |
| `sa` / `sd` / `sr` | Add / delete / replace surrounding |
| `<C-d>` / `<C-u>` | Scroll down / up (cursor stays centred) |
| `J` / `K` (visual) | Move selection down / up |
| `<leader>p` (visual) | Paste without clobbering register |
| `<leader>dd` | Delete without yanking |

### Terminal & Misc

| Key | Action |
|---|---|
| `<leader>ft` / `<C-/>` | Open floating terminal |
| `<leader>z` / `<leader>Z` | Zen mode / zoom |
| `<leader>.` | Toggle scratch buffer |
| `<Esc>` | Clear search highlight |

---

## Colorscheme

Uses `atraides/neovim-ayu`. Switches automatically between variants when macOS appearance changes:

- **Dark** → `ayu-mirage`
- **Light** → `ayu-light`

No manual toggle needed.

---

## Language Support

| Language | LSP | Formatter | Linter |
|---|---|---|---|
| Python | `pyright` + `ruff` | `ruff_format` → `black` | ruff (via LSP) |
| Go | `gopls` | `goimports` → `gofmt` | `golangci-lint` |
| bash/zsh | `bash-language-server` | `shfmt` | `shellcheck` |
| YAML / K8s | `yaml-language-server` + SchemaStore | — | `yamllint` |
| Helm | `helm-ls` | — | — |
| GitHub Actions | `gh-actions-language-server` | — | `actionlint` |
| Lua | `lua-language-server` | `stylua` | — |
| JSON | `biome` | `biome` → `prettier` | biome |

Python virtual environments are auto-detected from `.venv/`, `venv/`, `pyenv`, `poetry`, and `uv`.

Helm templates (`templates/*.yaml`) and GitHub Actions workflows (`.github/workflows/*.yml`) each
get their own filetype and LSP — they never conflict with `yamlls`.

---

## Portability

`git clone` + `nvim` is the entire install process. Mason handles every tool automatically.
No system-level package installation is needed beyond the prerequisites above.

Plugin versions are pinned in `lazy-lock.json`. To update intentionally:

```
:Lazy sync
```

Then review the changelog and commit `lazy-lock.json`.
