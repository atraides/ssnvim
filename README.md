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
| `<leader>:` | Command history |
| `<leader>fb` | Open buffers |
| `<leader>fr` | Recent files |
| `<leader>fp` | Projects |
| `<leader>e` | File explorer (snacks) |
| `-` | Open parent directory (oil.nvim) |

### Search (`<leader>s`)

| Key | Action |
|---|---|
| `<leader>sg` | Grep |
| `<leader>sw` | Grep word under cursor / visual selection |
| `<leader>sb` | Buffer lines |
| `<leader>sB` | Grep open buffers |
| `<leader>sd` | Project diagnostics |
| `<leader>sD` | Buffer diagnostics |
| `<leader>ss` | LSP document symbols |
| `<leader>sS` | LSP workspace symbols |
| `<leader>sk` | Keymaps |
| `<leader>sm` | Marks |
| `<leader>sj` | Jump list |
| `<leader>su` | Undo history |
| `<leader>sq` | Quickfix list |
| `<leader>sR` | Resume last picker |
| `<leader>sc` | Command history |
| `<leader>sC` | Commands |
| `<leader>sa` | Autocmds |
| `<leader>sH` | Highlights |
| `<leader>si` | Icons |
| `<leader>sl` | Location list |
| `<leader>sM` | Man pages |
| `<leader>sp` | Plugin specs (lazy) |
| `<leader>s"` | Registers |
| `<leader>s/` | Search history |

### Git

| Key | Action |
|---|---|
| `<leader>gg` | Open lazygit float |
| `<leader>gd` | Diff: git status |
| `<leader>gv` | Diff: repo history |
| `<leader>gV` | Diff: current file history |
| `<leader>gc` | Diff: compare revisions (prompts) |
| `<leader>gC` | Diff: file history with range |
| `<leader>g2` | Diff: compare two arbitrary files |
| `<leader>gB` | Open file on GitHub in browser |
| `<leader>gi` / `<leader>gI` | GitHub Issues (open / all) |
| `<leader>gp` / `<leader>gP` | GitHub Pull Requests (open / all) |
| `]h` / `[h` | Next / previous hunk |
| `]H` / `[H` | Last / first hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage buffer |
| `<leader>ghR` | Reset buffer |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghp` | Preview hunk inline |
| `<leader>ghb` | Blame line (full) |
| `<leader>ghB` | Blame buffer |
| `<leader>ghd` | Diff this |
| `ih` | Select hunk (text object, operator/visual) |

### LSP (active in buffers with LSP attached)

| Key | Action |
|---|---|
| `gd` | Go to definition (snacks picker) |
| `gD` | Go to declaration (snacks picker) |
| `gI` | Go to implementation (snacks picker) |
| `grf` | References (snacks picker) |
| `gy` | Go to type definition (snacks picker) |
| `K` | Hover docs |
| `gr` | References (quickfix, buffer-local) |
| `<leader>lr` | Rename symbol |
| `<leader>la` | Code actions |
| `<leader>ld` | Show diagnostic float |
| `<leader>lf` | Format buffer (LSP) |
| `[d` / `]d` | Previous / next diagnostic |

### Formatting

| Key | Action |
|---|---|
| `<leader>cf` | Format buffer (conform) |
| `<leader>cF` | Format injected languages |
| `<leader>cn` | ConformInfo |
| `<leader>uf` | Toggle autoformat on/off |

### Motion (flash.nvim)

| Key | Action |
|---|---|
| `m` | Flash jump (any visible location) |
| `M` | Flash treesitter (select by syntax node) |
| `r` | Remote flash (operator mode) |
| `R` | Treesitter search (operator/visual) |
| `<C-s>` | Toggle flash search (command mode) |

### Treesitter Text Objects & Motions

| Key | Mode | Action |
|---|---|---|
| `af` / `if` | x, o | Outer / inner function |
| `ac` / `ic` | x, o | Outer / inner class |
| `aa` / `ia` | x, o | Outer / inner parameter |
| `ad` | x, o | Comment |
| `as` | x, o | Statement |
| `]m` / `[m` | n, x, o | Next / prev function start |
| `]M` / `[M` | n, x, o | Next / prev function end |
| `]]` / `[[` | n, x, o | Next / prev class start |
| `]o` / `[o` | n, x, o | Next / prev loop |

### Editing

| Key | Action |
|---|---|
| `<space>m` | Toggle split/join block (treesj) |
| `<space>j` | Join block |
| `<space>k` | Split block |
| `sa` / `sd` / `sr` | Add / delete / replace surrounding |
| `sf` / `sF` | Find surrounding (right / left) |
| `sh` | Highlight surrounding |
| `<C-d>` / `<C-u>` | Scroll down / up (cursor stays centred) |
| `J` / `K` (visual) | Move selection down / up |
| `<` / `>` (visual) | Indent left / right (stays in visual) |
| `<leader>p` (visual) | Paste without clobbering register |
| `<leader>dd` | Delete without yanking |
| `<leader>cR` | Rename file |

### Buffer Management

| Key | Action |
|---|---|
| `<leader>bd` | Delete buffer |
| `<leader>bo` | Delete other buffers |
| `[b` / `]b` | Previous / next buffer |
| `[q` / `]q` | Previous / next quickfix item |

### UI Toggles (`<leader>u`)

| Key | Action |
|---|---|
| `<leader>us` | Toggle spelling |
| `<leader>uw` | Toggle line wrap |
| `<leader>ul` | Toggle line numbers |
| `<leader>uL` | Toggle relative numbers |
| `<leader>ud` | Toggle diagnostics |
| `<leader>uf` | Toggle autoformat |
| `<leader>uT` | Toggle treesitter |
| `<leader>ub` | Toggle dark/light background |
| `<leader>uC` | Browse colorschemes |
| `<leader>uc` | Toggle conceal level |
| `<leader>uA` | Toggle tabline |
| `<leader>uD` | Toggle dim |
| `<leader>ua` | Toggle animations |
| `<leader>ug` | Toggle indent guides |
| `<leader>uS` | Toggle smooth scroll |
| `<leader>uZ` | Toggle zoom |
| `<leader>uz` | Toggle zen |
| `<leader>wm` | Toggle window zoom |

### Terminal & Notifications

| Key | Action |
|---|---|
| `<leader>ft` | Open floating terminal (root dir) |
| `<leader>fT` | Open floating terminal (cwd) |
| `<C-/>` | Toggle terminal |
| `<leader>z` / `<leader>Z` | Zen mode / zoom |
| `<leader>.` | Toggle scratch buffer |
| `<leader>S` | Select scratch buffer |
| `<leader>n` | Notification history |
| `<leader>un` | Dismiss all notifications |
| `<Esc>` | Clear search highlight |

### Window Navigation

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move to left/down/up/right window |
| `<C-Up/Down>` | Increase / decrease window height |
| `<C-Left/Right>` | Decrease / increase window width |

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
