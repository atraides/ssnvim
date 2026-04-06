# ssnvim — Product Requirements Document

> **Version:** 2.1
> **Date:** 2026-04-06
> **Status:** Approved — All phases complete; reflects actual codebase state as of v0.4.0

---

## 1. Executive Summary

ssnvim is a custom, hand-crafted Neovim configuration built from a clean slate in the spirit of `kickstart.nvim` — every line is explicit, commented, and intentionally chosen. Unlike distribution-based setups (LazyVim, AstroNvim), ssnvim is owned entirely by the user: no abstraction layers, no upstream opinions that can break customizations, no magic. It is designed to be a daily-driver editor for a developer whose primary stack spans Python, Go, bash/zsh, Kubernetes, Helm, and ArgoCD.

The configuration prioritizes a lean plugin surface area using modern, high-performance tools. `snacks.nvim` consolidates functionality that would otherwise require 4–5 separate plugins (fuzzy finder, dashboard, terminal, lazygit integration, indent guides, notifications). `blink.cmp` replaces the heavier `nvim-cmp` for completion. `oil.nvim` replaces traditional sidebar file trees. The result is a fast, minimal, opinionated environment that feels native rather than assembled.

The configuration uses the owner's personal `atraides/neovim-ayu` colorscheme fork (ayu-mirage for dark, ayu-light for light mode) with `auto-dark-mode.nvim` tracking macOS appearance automatically. Navigation is augmented with `flash.nvim` for quick motion, `treesj` for smart block splitting/joining, and `mini.surround` for text object manipulation. Git workflows are supported by `gitsigns.nvim` for in-buffer decoration and `diffview.nvim` for rich diff views and file history.

**MVP Goal:** A working, minimal Neovim configuration that covers Python, Go, bash, YAML/Kubernetes, Helm, ArgoCD, and GitHub Actions editing with LSP, completion, formatting, linting, and Git integration — built incrementally so every piece is understood before the next is added.

---

## 2. Mission

**Mission statement:** Build the Neovim configuration you fully understand, can debug without searching the internet, and will use for the next decade.

### Core Principles

1. **Own every line** — No unexplained configuration. Every `vim.opt`, every keymap, every plugin spec is commented with its purpose.
2. **Modern and fast** — Prefer newer, faster implementations (blink.cmp over nvim-cmp, snacks.picker over Telescope) when they cover the required functionality.
3. **Minimal surface area** — The smallest number of plugins that achieve the required workflow. Add only when there is a clear, felt need.
4. **Portable by design** — `git clone` → `nvim` → fully functional on any machine. Mason handles all tool installation automatically.
5. **Incrementally built** — Each phase is fully functional before the next begins. No half-configured states committed to the repo.

---

## 3. Target Users

### Primary Persona: The User

| Attribute                 | Detail                                                                     |
| ------------------------- | -------------------------------------------------------------------------- |
| **Vim experience**        | 20+ years Vim, 2–3 months Neovim                                           |
| **Keybinding knowledge**  | Basics (hjkl, :wq, substitution) — wants to learn advanced, define own     |
| **Programming languages** | Python (primary), Go (secondary), bash/zsh                                 |
| **Python ecosystem**      | FastAPI, Typer, SQLModel, Rich, Textual; pyenv/poetry/uv                   |
| **Infrastructure**        | Kubernetes (multi-cluster, daily), Helm monorepos, ArgoCD Application YAML |
| **Git workflow**          | lazygit as primary UI, commitizen for commit messages                      |
| **Terminal**              | Ghostty — no tmux/zellij                                                   |
| **Philosophy**            | TUI-first, avoids GUIs, learns by doing, starts minimal                    |

### Key Pain Points

- Existing AstroNvim setup is a black box — hard to debug, hard to modify
- Wants Helm/ArgoCD YAML to work properly (schema validation, correct LSP behavior)
- Needs Kubernetes context visible and switchable without leaving the editor
- GitHub Copilot must work within enterprise policy (Neovim is officially supported)
- Colorscheme must follow macOS dark/light mode automatically

---

## 4. MVP Scope

### Core Functionality

| Feature                                                                                    | Status   |
| ------------------------------------------------------------------------------------------ | -------- |
| ✅ Sensible Neovim defaults (options, keymaps, autocmds)                                   | Complete |
| ✅ lazy.nvim plugin manager with lockfile                                                  | Complete |
| ✅ Ayu colorscheme (ayu-light=light, ayu-mirage=dark) with OS auto-switch                  | Complete |
| ✅ lualine statusline (mode, branch, filename, diff, diagnostics, LSP status, position)    | Complete |
| ✅ snacks.nvim: picker (fuzzy find), dashboard, indent guides, notifier                    | Complete |
| ✅ snacks.nvim: lazygit float (`<leader>gg`)                                               | Complete |
| ✅ snacks.nvim: floating terminal                                                          | Complete |
| ✅ snacks.nvim: GitHub Issues/PR pickers (`<leader>gi/gI/gp/gP`)                           | Complete |
| ✅ noice.nvim cmdline/message UI overhaul                                                  | Complete |
| ✅ todo-comments.nvim                                                                      | Complete |
| ✅ oil.nvim file manager                                                                   | Complete |
| ✅ which-key.nvim keybinding discovery                                                     | Complete |
| ✅ gitsigns.nvim for in-buffer git decorations and hunk operations                         | Complete |
| ✅ diffview.nvim rich diff view and file history                                           | Complete |
| ✅ flash.nvim enhanced motion with jump labels                                             | Complete |
| ✅ treesj split/join blocks (treesitter-aware)                                             | Complete |
| ✅ mini.surround text object surround operations                                           | Complete |
| ✅ mini.pairs auto-close brackets and quotes                                               | Complete |
| ✅ nvim-treesitter + all required parsers                                                  | Complete |
| ✅ nvim-treesitter-textobjects                                                             | Complete |
| ✅ Helm filetype detection (templates/\*.yaml → ft=helm)                                   | Complete |
| ✅ mason.nvim + mason-lspconfig + nvim-lspconfig                                           | Complete |
| ✅ LSP: pyright + ruff (Python)                                                            | Complete |
| ✅ LSP: gopls (Go)                                                                         | Complete |
| ✅ LSP: bash-language-server (bash/zsh)                                                    | Complete |
| ✅ LSP: yaml-language-server + SchemaStore (K8s, Helm, ArgoCD schemas)                     | Complete |
| ✅ LSP: helm-ls (Helm charts)                                                              | Complete |
| ✅ LSP: lua-ls (Neovim config itself)                                                      | Complete |
| ✅ LSP: biome (JSON formatting + linting)                                                  | Complete |
| ✅ blink.cmp completion engine                                                             | Complete |
| ✅ GitHub Copilot via copilot.lua + blink-copilot                                          | Complete |
| ✅ conform.nvim format-on-save                                                             | Complete |
| ✅ nvim-lint async linting                                                                 | Complete |
| ✅ Python venv auto-detection (pyenv, poetry, uv)                                          | Complete |
| ✅ README with install instructions and keybinding reference                               | Complete |
| ✅ GitHub Actions filetype detection (`yaml.github-actions` for `.github/workflows/*.yml`) | Complete |
| ✅ LSP: gh-actions-language-server (GitHub Actions workflows)                              | Complete |
| ✅ Linting: actionlint async linting for GitHub Actions workflows                          | Complete |
| ✅ gh-actions.nvim: treesitter-based `${{ }}` expression syntax highlighting               | Complete |

### Out of Scope (Future Phases)

| Feature                                         | Status                          |
| ----------------------------------------------- | ------------------------------- |
| ❌ Kubernetes context component in lualine      | Deferred — partially spec'd     |
| ~~❌ nvim-autopairs auto-close brackets/quotes~~ | Superseded by mini.pairs        |
| ❌ DAP / step-through debugging (Python, Go)    | Deferred                        |
| ❌ Bufferline / tab bar                         | Deferred (may not be needed)    |
| ❌ trouble.nvim project diagnostic list         | Deferred                        |
| ❌ neogit / vim-fugitive Git UI                 | Deferred (lazygit covers needs) |
| ❌ kubectl/helm commands from within Neovim     | Deferred                        |
| ❌ Test runner integration (pytest, go test)    | Deferred                        |
| ❌ AI chat (Claude, Copilot Chat) within Neovim | Deferred                        |
| ❌ Remote/SSH editing                           | Deferred                        |

---

## 5. User Stories

### US-1: Cross-machine portability

> As a developer who works on multiple machines, I want to clone my config repo and immediately have a fully configured Neovim, so that I never need to manually install language servers or configure plugins on a new machine.

- **Acceptance:** `git clone <repo> ~/.config/nvim && nvim` installs all plugins and tools automatically on first launch.

### US-2: Python development

> As a Python developer using FastAPI and Typer, I want type checking, import resolution, inline diagnostics, and format-on-save, so that I catch errors without leaving the editor.

- **Acceptance:** Pyright shows type errors inline; `ruff format` runs on save; virtual environments from pyenv, poetry, and uv are auto-detected.

### US-3: Kubernetes YAML editing

> As a Kubernetes cluster administrator, I want schema-validated YAML editing with completions for API fields, so that I write correct manifests without memorizing the API spec.

- **Acceptance:** `yaml-language-server` with SchemaStore provides completions and validation for Kubernetes manifests, ArgoCD Application CRDs, and Helm values schemas.

### US-4: Helm chart authoring

> As a Helm chart maintainer working with monorepos, I want correct syntax highlighting and LSP support for Helm templates, so that Go template syntax and YAML are both handled correctly.

- **Acceptance:** Files in `templates/` directories are detected as `ft=helm`; `helm-ls` attaches; `yaml-language-server` does not conflict.

### US-9: GitHub Actions workflow authoring

> As a developer who maintains CI/CD pipelines using GitHub Actions, I want completions, diagnostics, and syntax highlighting for workflow files, so that I catch expression errors and invalid workflow keys without leaving the editor.

- **Acceptance:** Files in `.github/workflows/` are detected as `yaml.github-actions`; `gh_actions_ls` attaches and provides completions for `on:`, `jobs:`, `steps:`, `uses:`, and `${{ }}` expressions; `actionlint` reports diagnostics on save; `yamlls` does not attach to workflow files; `${{ secrets.FOO }}` expressions are correctly highlighted by the treesitter `gh_actions_expressions` grammar.

### US-5: Git workflow

> As a developer who relies on lazygit, I want to open lazygit as a floating window from within Neovim with a single keybinding, so that I can review, stage, and commit without switching applications.

- **Acceptance:** `<leader>gg` opens lazygit in a snacks float; closing it returns cursor to exact previous position.

### US-6: Multi-cluster Kubernetes context awareness

> As someone working with multiple Kubernetes clusters, I want the current kubectl context visible in the statusline, so that I always know which cluster I'm targeting.

- **Status:** ⚠️ Deferred — the lualine statusline does not yet include a K8s context component. This was specified in the original PRD but not yet implemented. A future phase should add a cached `kubectl config current-context` component.

### US-7: Keybinding discoverability

> As a developer still learning Neovim's advanced features, I want to see available keybindings when I press a leader-key prefix, so that I can discover and remember commands without consulting documentation.

- **Acceptance:** which-key shows a popup after `<leader>` pause; all custom keybindings are registered with descriptive labels.

### US-8: Appearance that respects the OS

> As someone who works in both light and dark environments, I want my colorscheme to automatically switch between Ayu Light and Ayu Mirage when macOS changes appearance, so that I never manually toggle the theme.

- **Acceptance:** Changing macOS appearance (System Settings → Appearance) updates Neovim's colorscheme within 1–2 seconds without any manual intervention. Dark = `ayu-mirage`, Light = `ayu-light`.

---

## 6. Core Architecture & Patterns

### Architecture Overview

ssnvim follows a **module-per-concern** pattern inspired by kickstart.nvim's multi-file extension. The `init.lua` entry point is kept minimal — it only loads the `config` modules and bootstraps lazy.nvim. All plugin specifications live in `lua/plugins/`, grouped by functional area.

### Directory Structure

```
~/.config/nvim/          (symlinked or cloned from GitHub)
├── init.lua             # Entry: set leader keys, bootstrap lazy.nvim, require config
├── CHANGELOG.md         # Version history (managed with commitizen)
├── .cz.toml             # Commitizen configuration
├── lua/
│   ├── config/
│   │   ├── init.lua     # Loads options, keymaps, autocmds
│   │   ├── options.lua  # vim.opt.* — editor behavior
│   │   ├── keymaps.lua  # Non-plugin keymaps (window nav, misc utilities)
│   │   └── autocmds.lua # Autocommands (Helm/GHA ftdetect, yank highlight, etc.)
│   └── plugins/
│       ├── init.lua        # Empty placeholder (returns {})
│       ├── ui.lua          # neovim-ayu, auto-dark-mode, lualine, noice, todo-comments
│       ├── snacks.lua      # snacks.nvim (picker, dashboard, lazygit, terminal, gh, etc.)
│       ├── editor.lua      # oil.nvim, which-key, flash, treesj, mini.surround
│       ├── git.lua         # gitsigns, diffview.nvim
│       ├── treesitter.lua  # nvim-treesitter + textobjects + gh-actions.nvim
│       ├── lsp.lua         # mason + mason-lspconfig + nvim-lspconfig + SchemaStore
│       ├── completion.lua  # blink.cmp + copilot.lua + blink-copilot
│       ├── formatting.lua  # conform.nvim
│       └── linting.lua     # nvim-lint
├── lazy-lock.json       # Committed — reproducible installs
├── .gitignore
└── README.md
```

### Key Design Patterns

**Plugin specification pattern (lazy.nvim):**

```lua
-- lua/plugins/editor.lua
return {
  {
    "stevearc/oil.nvim",
    lazy = false,        -- load immediately (file manager must be available from startup)
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {},
  },
}
```

**Filetype-scoped lazy loading:**

```lua
{ "plugin/name", ft = { "python", "go" } }   -- only load for these filetypes
{ "plugin/name", event = "LspAttach" }        -- load when LSP attaches
{ "plugin/name", cmd = "SomeCommand" }        -- load on first command use
```

**Helm filetype detection (autocmds.lua):**

```lua
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.yml"]  = "helm",
    [".*/templates/.*%.tpl"]  = "helm",
    ["helmfile.*%.yaml"]      = "helm",
  },
})
```

**GitHub Actions filetype detection (autocmds.lua):**

```lua
vim.filetype.add({
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.github-actions",
  },
})
```

**OS-aware colorscheme (auto-dark-mode.nvim):**

```lua
require("auto-dark-mode").setup({
  update_interval = 1000,
  set_dark_mode = function()
    vim.cmd("colorscheme ayu-mirage")
  end,
  set_light_mode = function()
    vim.cmd("colorscheme ayu-light")
  end,
})
```

**K8s statusline component (not yet implemented):**

```lua
-- TODO: Future phase — add cached kubectl context to lualine
-- Cache the result; invalidate only on BufEnter/FocusGained
-- to avoid calling io.popen on every statusline redraw.
local function k8s_context()
  local handle = io.popen("kubectl config current-context 2>/dev/null")
  if not handle then return "" end
  local result = handle:read("*a"):gsub("\n", "")
  handle:close()
  return result ~= "" and ("⎈ " .. result) or ""
end
```

---

## 7. Feature Specifications

### 7.1 snacks.nvim — The Core Hub

snacks.nvim is configured as the primary multi-tool, replacing what would otherwise be 5+ plugins:

**Enabled modules:** `animate`, `bigfile`, `bufdelete`, `dashboard`, `dim`, `explorer`, `gh`, `gitbrowse`, `indent`, `input`, `layout`, `lazygit`, `notifier`, `quickfile`, `rename`, `scope`, `scratch`, `scroll`, `statuscolumn`, `terminal`, `toggle`, `words`, `zen`

| Module                   | Keybinding           | Description                              |
| ------------------------ | -------------------- | ---------------------------------------- |
| `picker.files`           | `<leader>ff`         | Find files (respects .gitignore)         |
| `picker.files`           | `<leader><space>`    | Smart find files                         |
| `picker.grep`            | `<leader>/`          | Live grep across project                 |
| `picker.grep`            | `<leader>sg`         | Grep                                     |
| `picker.grep_word`       | `<leader>sw`         | Grep word / visual selection             |
| `picker.buffers`         | `<leader>fb`         | Switch open buffers                      |
| `picker.recent`          | `<leader>fr`         | Recent files                             |
| `picker.projects`        | `<leader>fp`         | Projects                                 |
| `picker.lsp_symbols`     | `<leader>ss`         | LSP document symbols                     |
| `picker.lsp_workspace_symbols` | `<leader>sS`   | LSP workspace symbols                    |
| `picker.diagnostics`     | `<leader>sd`         | Project diagnostics                      |
| `picker.diagnostics_buffer` | `<leader>sD`      | Buffer diagnostics                       |
| `picker.command_history` | `<leader>:`          | Command history                          |
| `picker.lsp_definitions` | `gd`                 | Go to definition (picker)                |
| `picker.lsp_declarations`| `gD`                 | Go to declaration (picker)               |
| `picker.lsp_references`  | `grf`                | References (picker)                      |
| `picker.lsp_implementations` | `gI`             | Go to implementation (picker)            |
| `picker.lsp_type_definitions` | `gy`            | Go to type definition (picker)           |
| `lazygit`                | `<leader>gg`         | Open lazygit float                       |
| `terminal`               | `<leader>ft`/`<c-/>` | Open floating terminal                   |
| `terminal` (cwd)         | `<leader>fT`         | Open terminal in cwd                     |
| `dashboard`              | (startup)            | Dashboard on `nvim` with no args         |
| `notifier`               | (automatic)          | Replaces vim.notify                      |
| `notifier.show_history`  | `<leader>n`          | Notification history                     |
| `notifier.hide`          | `<leader>un`         | Dismiss all notifications                |
| `indent`                 | (automatic)          | Indent guides on all buffers             |
| `explorer`               | `<leader>e`          | File explorer (snacks-based)             |
| `gh.issues`              | `<leader>gi/gI`      | GitHub Issues (open / all)               |
| `gh.prs`                 | `<leader>gp/gP`      | GitHub Pull Requests (open / all)        |
| `gitbrowse`              | `<leader>gB`         | Open file/selection on GitHub in browser |
| `zen`                    | `<leader>z/Z`        | Zen mode / zoom                          |
| `scratch`                | `<leader>.`          | Toggle scratch buffer                    |
| `scratch.select`         | `<leader>S`          | Select scratch buffer                    |
| `rename.rename_file`     | `<leader>cR`         | Rename file                              |
| `bufdelete`              | `<leader>bd`         | Delete buffer                            |
| `bufdelete.other`        | `<leader>bo`         | Delete other buffers                     |

### 7.2 LSP Configuration

Each language server is configured with explicit settings, not defaults.

**Python (pyright):**

- `pythonPath` auto-detected from active virtual environment (`before_init` hook checks `.venv/bin/python` and `venv/bin/python`)
- `typeCheckingMode = "strict"`
- `autoSearchPaths = true`, `useLibraryCodeForTypes = true`

**YAML (yamlls + SchemaStore):**

- `schemaStore.enable = false` (use SchemaStore.nvim catalog instead)
- `schemas = require("schemastore").yaml.schemas()` — auto-applies schemas for Kubernetes, Helm values, ArgoCD, Docker Compose, etc.
- Filetypes restricted to `{ "yaml", "yaml.docker-compose" }` — explicitly excludes `helm` and `yaml.github-actions`

**Helm (helm-ls):**

- Only attaches to `ft=helm` files
- `yamlls` explicitly excluded from Helm buffers

**GitHub Actions (gh_actions_ls):**

- Mason package: `gh-actions-language-server`
- lspconfig server name: `gh_actions_ls`
- Filetype: `{ "yaml.github-actions" }` — clean separation from yamlls (mirrors Helm pattern)
- `flags = { allow_incremental_sync = false }` — workaround for a textEdit crash bug where the server sends positions exceeding the buffer's line count
- Provides: completions for `on:`, `jobs:`, `steps:`, `uses:`, `with:` keys; hover docs; `${{ }}` expression context awareness; semantic tokens

**Biome (biome):**

- Used for JSON formatting and linting
- Requires a `biome.json` config file in the project root (`require_cwd = true` in conform)
- Falls through to `prettier` if no biome.json present

**LSP attach keymaps** (buffer-local, `LspAttach` autocmd):

| Key          | Action                       |
| ------------ | ---------------------------- |
| `gd`         | `vim.lsp.buf.definition`     |
| `gD`         | `vim.lsp.buf.declaration`    |
| `gI`         | `vim.lsp.buf.implementation` |
| `K`          | `vim.lsp.buf.hover`          |
| `gr`         | `vim.lsp.buf.references`     |
| `<leader>lr` | `vim.lsp.buf.rename`         |
| `<leader>la` | `vim.lsp.buf.code_action`    |
| `<leader>ld` | `vim.diagnostic.open_float`  |
| `<leader>lf` | `vim.lsp.buf.format` (async) |

> **Note:** `gd`, `gD`, `gI` are also defined in `snacks.lua` as picker-based navigation (`grf` for references, `gy` for type definitions). The snacks keys are global; the LspAttach versions are buffer-local. In LSP buffers, the buffer-local bindings take precedence for `gd`/`gD`/`gI`. `grf` and `gy` are snacks-only (no LspAttach equivalent).

### 7.3 Completion Stack

```
blink.cmp (version = "1.*", pre-built Rust binary)
├── source: lsp        (primary — LSP completions)
├── source: copilot    (via blink-copilot — score_offset = 100, async = true)
├── source: path       (filesystem paths)
├── source: buffer     (words from open buffers)
└── source: snippets   (blink.cmp built-in snippet support)
```

- `keymap.preset = "super-tab"` — Tab cycles through completions
- `completion.ghost_text.enabled = true` — Copilot-style inline ghost text
- `completion.documentation.auto_show = false` — docs shown on demand

### 7.4 Formatting (conform.nvim)

Format-on-save enabled for all configured filetypes. Auto-format is skipped for `sql`, `yaml`, `yml`, files in `node_modules/`, and when `vim.g.disable_autoformat` or `vim.b.disable_autoformat` is set.

| Filetype            | Formatter(s)                    | Notes                                          |
| ------------------- | ------------------------------- | ---------------------------------------------- |
| `lua`               | `stylua`                        |                                                |
| `go`                | `goimports` → `gofmt`           | `stop_after_first = true`                      |
| `python`            | `ruff_format` → `black`         | `stop_after_first = true`                      |
| `json`              | `biome` → `prettier`            | `stop_after_first = true`; biome requires cwd  |
| `markdown`          | `prettier`                      |                                                |
| `css`               | `prettier`                      |                                                |
| `html`              | `prettier`                      |                                                |
| `toml`              | `taplo`                         |                                                |
| `sh`, `bash`, `zsh` | `shfmt`                         |                                                |
| Everything else     | LSP (`lsp_format = "fallback"`) | Falls back to LSP formatter if no conform rule |

**Format keymaps:**

| Key          | Mode | Action                             |
| ------------ | ---- | ---------------------------------- |
| `<leader>cf` | n, v | Format buffer                      |
| `<leader>cF` | n, v | Format injected languages (3000ms) |
| `<leader>cn` | n, v | `:ConformInfo`                     |
| `<leader>uf` | n    | Toggle autoformat (global)         |
### 7.5 Linting (nvim-lint)

Async linting triggered on `BufWritePost` and `BufReadPost`. Python is intentionally excluded — the `ruff` LSP server handles diagnostics directly without needing a separate linter process.

| Filetype              | Linter(s)       | Notes                                                                                  |
| --------------------- | --------------- | -------------------------------------------------------------------------------------- |
| `go`                  | `golangci_lint` |                                                                                        |
| `sh`, `bash`, `zsh`   | `shellcheck`    |                                                                                        |
| `yaml`                | `yamllint`      |                                                                                        |
| `yaml.github-actions` | `actionlint`    | Explicit call (not via `linters_by_ft` split); yamllint does NOT run on workflow files |

**actionlint notes:**

- Registered under `yaml.github-actions` only to avoid running on every YAML save
- A separate `FileType yaml.github-actions` autocmd handles the lazy-load timing edge case for the first buffer opened

### 7.6 Git Integration

Two plugins handle git functionality, each with a distinct role:

**gitsigns.nvim** — in-buffer decorations and hunk operations:

- Current line blame (`current_line_blame = true`)
- Signs: `▎` add/change, `delete,` topdelete
- Hunk navigation: `]h` / `[h` (next/prev), `]H` / `[H` (last/first)
- Full hunk operations under `<leader>gh*` prefix
- `ih` text object for selecting a hunk in operator/visual mode

**diffview.nvim** — rich diff views and file history:

- Uses `dlyongemallo/diffview.nvim` fork (HACK: upstream `sindrets/diffview.nvim` is unmaintained)
- `enhanced_diff_hl = true`, `watch_index = true`
- Opened via `<leader>gd` (git status diff), `<leader>gv` (repo history), `<leader>gV` (current file history)
- `<leader>gc` — compare revisions (prompts for ref); `<leader>gC` — file history with range
- `<leader>g2` — compare two arbitrary files side by side
- Merge conflict resolution: `<leader>co/ct/cb/cx` for ours/theirs/both/delete

### 7.7 Enhanced Editing

Three plugins extend editing capabilities beyond Neovim's native features:

**flash.nvim** — enhanced motion with jump labels:

- `m` — flash jump (any visible location)
- `M` — flash treesitter (select by syntax node)
- `r` / `R` — remote flash / treesitter search (operator mode)
- `<c-s>` in command mode — toggle flash search

**treesj** — split/join code blocks (treesitter-aware):

- `<space>m` — toggle split/join
- `<space>j` — join block
- `<space>k` — split block

**mini.surround** — surround text objects:

- `sa` / `sd` / `sr` — add / delete / replace surrounding
- `sf` / `sF` — find surrounding right / left
- `sh` — highlight surrounding

**mini.pairs** — auto-close brackets and quotes:

- Default settings: auto-closes `()`, `[]`, `{}`, `""`, `''`, ` `` `
- Configured with `require("mini.pairs").setup({})` — zero custom overrides
- Part of the `nvim-mini/mini.nvim` ecosystem (same org as `mini.surround`)

---

## 8. Technology Stack

### Core

| Component      | Choice    | Version                            |
| -------------- | --------- | ---------------------------------- |
| Editor         | Neovim    | 0.11+ (0.12 when stable)           |
| Plugin manager | lazy.nvim | latest (pinned via lazy-lock.json) |
| Language       | Lua       | 5.1 (LuaJIT, bundled with Neovim)  |

### Plugins

| Plugin                                        | Purpose                                                     |
| --------------------------------------------- | ----------------------------------------------------------- |
| `folke/lazy.nvim`                             | Plugin manager                                              |
| `atraides/neovim-ayu`                         | Primary colorscheme (ayu-mirage dark, ayu-light light)      |
| `f-person/auto-dark-mode.nvim`                | macOS dark/light mode sync (polls every 1000ms)             |
| `nvim-lualine/lualine.nvim`                   | Statusline                                                  |
| `folke/noice.nvim`                            | Enhanced cmdline, message, and notification UI              |
| `MunifTanjim/nui.nvim`                        | UI component library (noice dependency)                     |
| `folke/todo-comments.nvim`                    | Highlight and search TODO/FIXME/NOTE/HACK/PERF comments     |
| `nvim-lua/plenary.nvim`                       | Lua utility library (todo-comments dependency)              |
| `folke/snacks.nvim`                           | Picker, dashboard, lazygit, terminal, gh, indent, notifier  |
| `nvim-tree/nvim-web-devicons`                 | File icons (snacks/oil dependency)                          |
| `stevearc/oil.nvim`                           | File manager (filesystem-as-buffer)                         |
| `folke/which-key.nvim`                        | Keybinding discovery popup                                  |
| `folke/flash.nvim`                            | Enhanced motion and search with jump labels                 |
| `Wansmer/treesj`                              | Split/join code blocks (treesitter-aware)                   |
| `nvim-mini/mini.surround`                     | Surround text objects                                       |
| `nvim-mini/mini.pairs`                        | Auto-close brackets, quotes, and other pairs                |
| `lewis6991/gitsigns.nvim`                     | Git signs + hunk operations + blame                         |
| `dlyongemallo/diffview.nvim`                  | Rich side-by-side diffs and file history (fork of sindrets) |
| `nvim-treesitter/nvim-treesitter`             | Syntax highlighting and treesitter infrastructure           |
| `nvim-treesitter/nvim-treesitter-textobjects` | Treesitter-based text objects and motions                   |
| `Hdoc1509/gh-actions.nvim`                    | GitHub Actions `${{ }}` expression treesitter grammar       |
| `williamboman/mason.nvim`                     | LSP/tool installer                                          |
| `williamboman/mason-lspconfig.nvim`           | Mason ↔ lspconfig bridge                                    |
| `neovim/nvim-lspconfig`                       | LSP client configurations                                   |
| `b0o/schemastore.nvim`                        | JSON/YAML schema catalog                                    |
| `saghen/blink.cmp`                            | Completion engine (pre-built Rust binary)                   |
| `zbirenbaum/copilot.lua`                      | GitHub Copilot                                              |
| `fang2hou/blink-copilot`                      | Copilot → blink.cmp bridge                                  |
| `stevearc/conform.nvim`                       | Formatter runner                                            |
| `mfussenegger/nvim-lint`                      | Async linter runner                                         |

**Total plugin specs: 29** (lazy-lock.json entries; includes transitive dependencies)

> **Note:** `nvim-autopairs` was in the original specification but was superseded by `mini.pairs` (from the `nvim-mini/mini.nvim` ecosystem). `mini.pairs` was chosen because `mini.surround` already pulls in the same ecosystem, making it lighter-weight than adding a separate `nvim-autopairs` dependency, while providing equivalent auto-close functionality for `()`, `[]`, `{}`, `""`, `''`, and ` `` `.

> **Note:** `dlyongemallo/diffview.nvim` is a fork used because the upstream `sindrets/diffview.nvim` is unmaintained. Marked with a `-- HACK` comment in `git.lua`. Monitor for a maintained alternative or upstream revival.

**gh-actions.nvim notes:**

- Provides treesitter-based syntax highlighting for `${{ }}` expression syntax in GitHub Actions workflows
- Requires a custom `gh_actions_expressions` treesitter parser (not in the standard nvim-treesitter catalog)
- Setup requires calling `require("gh-actions.tree-sitter").setup()` before parser installation to register the custom parser source — this ordering is critical
- Does not register its own filetype — relies on the `yaml.github-actions` filetype set by `autocmds.lua`

### Language Servers (installed by Mason)

| Server (lspconfig name) | Mason package                | Language                                                                 |
| ----------------------- | ---------------------------- | ------------------------------------------------------------------------ |
| `biome`                 | `biome`                      | JSON formatting + linting                                                |
| `pyright`               | `pyright`                    | Python type checking                                                     |
| `ruff`                  | `ruff`                       | Python linting + code actions + formatting                               |
| `gopls`                 | `gopls`                      | Go                                                                       |
| `bashls`                | `bash-language-server`       | Bash, sh, zsh                                                            |
| `yamlls`                | `yaml-language-server`       | YAML / Kubernetes / Helm values (not Helm templates, not GitHub Actions) |
| `helm_ls`               | `helm-ls`                    | Helm templates                                                           |
| `gh_actions_ls`         | `gh-actions-language-server` | GitHub Actions workflows (yaml.github-actions ft only)                   |
| `lua_ls`                | `lua-language-server`        | Lua (Neovim config)                                                      |

### Non-LSP Tools (installed by Mason)

| Tool            | Purpose                       |
| --------------- | ----------------------------- |
| `goimports`     | Go import management + format |
| `shfmt`         | Shell script formatting       |
| `stylua`        | Lua formatting                |
| `prettier`      | JS/TS/HTML/CSS/Markdown/JSON  |
| `taplo`         | TOML formatting               |
| `black`         | Python formatting (fallback)  |
| `golangci-lint` | Go multi-linter               |
| `shellcheck`    | Shell linting                 |
| `yamllint`      | YAML linting                  |
| `actionlint`    | GitHub Actions linting        |

### External Tools (assumed present on developer machines)

| Tool         | Purpose                                                  |
| ------------ | -------------------------------------------------------- |
| `lazygit`    | Git TUI (opened via snacks.lazygit)                      |
| `commitizen` | Conventional commit messages                             |
| `kubectl`    | Kubernetes CLI (context for future statusline component) |
| `helm`       | Helm CLI                                                 |
| `pyenv`      | Python version + virtualenv management                   |
| `poetry`     | Python dependency management                             |
| `uv`         | Fast Python package manager                              |

---

## 9. Security & Configuration

### Authentication

- **GitHub Copilot:** Enterprise OAuth via `:Copilot auth` on first launch. Token stored in `~/.config/github-copilot/`. The enterprise subscription explicitly supports Neovim as an IDE.
- **No API keys** are stored in the config repository. All secrets remain in system-level credential stores.

### Sensitive Data Handling

- `lazy-lock.json` is committed — contains only public plugin commit hashes, no secrets.
- `.gitignore` excludes: `.luarc.json`, `*.log`, any file matching `*.env`.
- The `~/.kube/config` is read at runtime for the K8s context statusline component (future) — never written or modified by the config.

### Portability Considerations

- All paths use `vim.fn.stdpath()` for cross-machine compatibility.
- Mason installs tools to `~/.local/share/nvim/mason/` — no system-level write access required.
- Python virtual environment detection uses relative paths and standard conventions — no hardcoded absolute paths.

---

## 10. Success Criteria

### MVP Definition

The MVP is complete when:

✅ `git clone <repo> ~/.config/nvim && nvim` fully bootstraps on a fresh machine without manual steps
✅ All language servers install automatically via Mason on first launch
✅ Python files in a FastAPI project show pyright type errors and ruff lint diagnostics
✅ YAML files in a Kubernetes manifest directory show schema-validated completions
✅ Helm `templates/*.yaml` files are detected as `ft=helm` and use `helm-ls`, not `yamlls`
✅ `<leader>gg` opens lazygit as a floating window
✅ Ayu colorscheme switches automatically between light and mirage when macOS appearance changes
✅ GitHub Copilot completions appear in blink.cmp alongside LSP completions
✅ Format-on-save runs for Python, Go, bash, and Lua files
✅ `<leader>` + pause shows which-key popup with all registered bindings
✅ `README.md` documents installation and all non-obvious keybindings
✅ Files in `.github/workflows/` are detected as `yaml.github-actions`; `gh_actions_ls` attaches and `yamlls` does not
✅ `actionlint` reports diagnostics on save for GitHub Actions workflow files
✅ `${{ secrets.FOO }}` expressions are highlighted by the `gh_actions_expressions` treesitter grammar

⚠️ **Not yet complete:** Current kubectl context in the statusline (US-6) — deferred to a future phase.

### Quality Indicators

- Neovim startup time: < 100ms (cold, no file) measured with `--startuptime`
- No plugin errors in `:checkhealth`
- All Mason tools show green in `:Mason`
- `lazy-lock.json` committed and up-to-date

### User Experience Goals

- A new Python file in a poetry project: LSP attaches within 2 seconds, completions work immediately
- Opening a Helm chart: correct filetype detected, helm-ls attaches, no yamlls errors
- Pressing `<leader>` in Normal mode: which-key popup appears within 300ms with all keybindings categorized

---

## 11. Implementation Phases

### Phase 1 — Foundation ✅

**Goal:** Working Neovim with sensible defaults, no plugins.

✅ `init.lua` — bootstrap lazy.nvim, load config modules
✅ `lua/config/options.lua` — line numbers, tab settings, search, clipboard, sign column, folds, etc.
✅ `lua/config/keymaps.lua` — window navigation, buffer navigation, scroll centring, visual indent
✅ `lua/config/autocmds.lua` — Helm filetype detection, trailing whitespace trim, highlight on yank, cursor restore
✅ `.gitignore` and initial `README.md`
✅ First commit pushed to GitHub

**Validation:** `nvim` opens, `:set number?` shows `number`, Helm `.yaml` files detected correctly.

---

### Phase 2 — Look & Feel ✅

**Goal:** Beautiful, informative UI baseline.

✅ `lua/plugins/ui.lua` — `neovim-ayu` + `auto-dark-mode`
✅ lualine with: mode (colored), branch, filename, diff, diagnostics (left); LSP status, location, progress (right)
✅ `noice.nvim` — enhanced cmdline and message UI (bottom search, command palette presets)
✅ `todo-comments.nvim` — TODO/FIXME/HACK/NOTE/PERF highlighting

**Validation:** Colorscheme switches on macOS appearance change; statusline shows LSP status; dashboard appears on bare `nvim`; noice replaces the default cmdline.

---

### Phase 3 — Navigation & Git ✅

**Goal:** Full file/code/project navigation.

✅ snacks.picker — files, grep, buffers, recent, projects, LSP symbols, diagnostics, and more
✅ snacks.lazygit — `<leader>gg` float
✅ snacks.terminal — `<leader>ft` / `<c-/>` float
✅ snacks.explorer — `<leader>e` file explorer
✅ snacks.gh — `<leader>gi/gI/gp/gP` GitHub Issues and PR pickers
✅ oil.nvim — `-` key to open parent directory
✅ which-key — all keybindings registered with descriptions and groups
✅ gitsigns — signs, hunk staging, blame, diff view
✅ diffview.nvim — `<leader>gd/gv/gV` for diffs and file history
✅ flash.nvim — `m`/`M` jump labels; `r`/`R` operator motions
✅ treesj — `<space>m/j/k` split/join blocks
✅ mini.surround — `sa/sd/sr/sf/sF/sh` surround operations

**Note:** `nvim-autopairs` was planned for this phase but `mini.pairs` was added instead. `mini.pairs` provides equivalent auto-close functionality and fits naturally into the existing `nvim-mini` ecosystem already used for `mini.surround`.

**Validation:** `<leader>ff` finds files; `<leader>gg` opens lazygit; `-` opens oil; `<leader>` shows which-key popup; `m` shows flash jump labels.

---

### Phase 4 — Treesitter ✅

**Goal:** Correct syntax highlighting for all languages.

✅ nvim-treesitter with parsers: `python`, `go`, `gomod`, `bash`, `yaml`, `helm`, `json`, `lua`, `markdown`, `markdown_inline`, `regex`, `dockerfile`
✅ nvim-treesitter-textobjects — `af/if/ac/ic/aa/ia/ad/as` text objects; `]m/[m/]]/[[` motions
✅ `gh-actions.nvim` installed; `require("gh-actions.tree-sitter").setup()` called before parser install
✅ `gh_actions_expressions` custom treesitter parser installed via nvim-treesitter

**Validation:** Open a Helm template — `{{ .Values.image.tag }}` highlights as a Go template expression. Open a GitHub Actions workflow — `${{ secrets.TOKEN }}` is highlighted with expression-level granularity.

---

### Phase 5 — LSP ✅

**Goal:** Full code intelligence for all languages.

✅ mason.nvim bootstrap and auto-install of all LSP servers and non-LSP tools
✅ nvim-lspconfig with server configs for: biome, pyright, ruff, gopls, bashls, yamlls, helm_ls, lua_ls, gh_actions_ls
✅ SchemaStore.nvim integrated with yamlls
✅ yamlls explicitly disabled for `ft=helm` and `yaml.github-actions` buffers
✅ `gh_actions_ls` configured with `filetypes = { "yaml.github-actions" }` and `allow_incremental_sync = false` workaround
✅ GitHub Actions filetype detection in `autocmds.lua`: `.github/workflows/*.yml` → `yaml.github-actions`
✅ Python venv auto-detection for pyenv, poetry, uv via `before_init` hook
✅ LSP keymaps: go-to-definition, hover, references, rename, code action, format (under `<leader>l*`)
✅ Diagnostic float on jump via `vim.diagnostic.config({ on_jump = { float = true } })`

**Validation:** Open a FastAPI project — pyright shows types; open a K8s manifest — completions include all API fields; open a Helm template — helm-ls attaches, yamlls does not; open `.github/workflows/ci.yml` — gh_actions_ls attaches, yamlls does not, actionlint diagnostics appear on save.

---

### Phase 6 — Completion ✅

**Goal:** Fast, AI-assisted completion.

✅ blink.cmp configured with LSP, path, buffer, snippet, and copilot sources
✅ copilot.lua installed and authenticated
✅ blink-copilot bridge configured (`score_offset = 100`, `async = true`, `max_completions = 3`)
✅ Ghost text enabled for inline Copilot-style suggestions

**Validation:** In a Python file, Copilot suggestions appear; LSP completions appear; Tab/Enter accept. `:Copilot status` shows authenticated.

---

### Phase 7 — Formatting & Linting ✅

**Goal:** Automatic code quality enforcement.

✅ conform.nvim format-on-save for: Python (ruff_format→black), Go (goimports→gofmt), bash (shfmt), Lua (stylua), JSON (biome→prettier), TOML (taplo), CSS/HTML/Markdown (prettier)
✅ nvim-lint async linting for: Go (golangci_lint), bash (shellcheck), YAML (yamllint), GitHub Actions (actionlint)
✅ Python excluded from nvim-lint — ruff LSP handles diagnostics directly
✅ `yaml.github-actions` uses actionlint only (yamllint excluded via explicit autocmd approach)
✅ `<leader>cf` keymap for manual format trigger; `<leader>uf` to toggle autoformat

**Validation:** Save a Python file with an unused import — ruff removes it; save a Go file — goimports runs; YAML with wrong indentation — yamllint marks it; save a workflow with an invalid expression — actionlint reports the error.

---

### Phase 8 — Polish & Documentation ✅

**Goal:** Repo is complete, documented, and push-button installable.

✅ `README.md` — installation steps, prerequisites, keybinding reference
✅ All which-key groups labeled and organized
✅ `:checkhealth` passes with no errors
✅ `lazy-lock.json` committed
✅ Startup time verified < 100ms
✅ `CHANGELOG.md` added; commitizen configured via `.cz.toml`

**Validation:** Fresh clone on a second machine bootstraps fully without intervention.

---

### Phase 9 — GitHub Actions Support ✅

**Goal:** Full GitHub Actions workflow editing: filetype detection, LSP, expression highlighting, and linting.

✅ `lua/config/autocmds.lua` — `yaml.github-actions` filetype pattern for `.github/workflows/*.{yml,yaml}`
✅ `lua/plugins/treesitter.lua` — `require("gh-actions.tree-sitter").setup()` called before parser installation; `gh_actions_expressions` in `ensure_installed`; `Hdoc1509/gh-actions.nvim` plugin spec
✅ `lua/plugins/lsp.lua` — `gh_actions_ls` in `ensure_installed`; `actionlint` in Mason non-LSP tools; `vim.lsp.config("gh_actions_ls", ...)` with `allow_incremental_sync = false` workaround; `yamlls` filetypes exclude `yaml.github-actions`
✅ `lua/plugins/linting.lua` — actionlint registered for `yaml.github-actions` via explicit autocmd (not `linters_by_ft` table split)
✅ `lazy-lock.json` committed

**Validation:** Open `.github/workflows/ci.yml` — `yaml.github-actions` filetype set; `gh_actions_ls` attaches (`:LspInfo`); `yamlls` does not; `${{ secrets.TOKEN }}` highlighted; save with invalid expression — actionlint shows diagnostic.

---

## 12. Future Considerations

### Post-MVP Enhancements (Priority Order)

1. **K8s context in lualine** — Implement a cached `kubectl config current-context` lualine component (US-6). Cache on `BufEnter`/`FocusGained`; avoid `io.popen` on every redraw.
2. **DAP / Debugging** — `nvim-dap` + `nvim-dap-ui` + `nvim-dap-python` for FastAPI/Typer debugging when print/pdb becomes insufficient.
4. **trouble.nvim** — Project-wide diagnostic list once the LSP setup is mature.
5. **nvim-treesitter-context** — Function/class context header for navigating large files.
6. **kubectl integration** — Consider `kubectl.nvim` or custom terminal commands for K8s operations.
7. **Test runner** — `neotest` with pytest and Go test adapters.
8. **AI chat** — Claude or Copilot Chat integration within Neovim.
9. **Bufferline** — Tab bar for open buffers, if navigation friction grows.
10. **sindrets/diffview.nvim** — Switch from the `dlyongemallo` fork back to the canonical repo if upstream resumes maintenance.

### Integration Opportunities

- **ArgoCD CLI** — `argocd` commands via snacks.terminal for quick app sync/status
- **Helm chart testing** — Pre-commit hooks with `chart-testing` (ct) for Helm monorepos
- **Remote/SSH editing** — Neovim's built-in `scp://` or `oil-ssh` for remote file editing

---

## 13. Risks & Mitigations

| Risk                                                                                                                                                    | Likelihood | Impact | Mitigation                                                                                                                                                                    |
| ------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Helm/YAML LSP conflict** — `yamlls` and `helm-ls` both attaching to Helm templates, causing noise/errors                                              | High       | High   | Explicit `filetypes` config on yamlls to exclude `helm` ft; `vim.filetype.add()` patterns in `autocmds.lua` run before any LSP attach                                         |
| **GitHub Actions / yamlls conflict** — `yamlls` attaches to `.github/workflows/*.yml` if `yaml.github-actions` filetype detection is missing or delayed | Medium     | Medium | `vim.filetype.add()` pattern runs before any BufRead/LSP autocmd; `yamlls` filetypes list explicitly omits `yaml.github-actions`; same proven pattern as Helm/yaml separation |
| **Copilot enterprise policy** — enterprise admin changes policy and blocks Neovim                                                                       | Low        | High   | Document the current allowed method; keep `copilot.lua` in its own file so it can be disabled cleanly without touching other config                                           |
| **snacks.nvim breaking changes** — Folke's active development means APIs shift                                                                          | Medium     | Medium | Commit `lazy-lock.json`; update intentionally, not automatically; read changelog before `:Lazy update`                                                                        |
| **Python venv not detected** — pyright picks up wrong Python or none, making completions useless                                                        | Medium     | High   | `before_init` hook checks `.venv/bin/python` and `venv/bin/python` in cwd; document manual override with `.pyrightconfig.json`                                                |
| **diffview.nvim fork divergence** — `dlyongemallo` fork may fall behind or introduce bugs vs. upstream                                                  | Medium     | Low    | Monitor upstream `sindrets/diffview.nvim` for revival; switch back when it becomes maintained again; fork is a drop-in replacement today                                      |
| **gh_actions_expressions parser not installed** — `gh-actions.nvim` silently does nothing if the custom treesitter parser is missing                    | Low        | Low    | `require("gh-actions.tree-sitter").setup()` must be called before `nvim-treesitter` installs parsers; ordering is enforced by the `dependencies` field in `treesitter.lua`    |
| **gh_actions_ls textEdit crash** — server sends positions exceeding buffer line count, crashing `vim/lsp/sync.lua`                                      | Low        | Medium | `flags = { allow_incremental_sync = false }` forces full-document sync; overhead is negligible on short workflow files; document this as a known workaround                   |
| **`[[`/`]]` keymap conflict** — both treesitter-textobjects (class navigation) and snacks.words (word reference) register these keys | Low | Low | treesitter-textobjects registers last and takes precedence; snacks.words `]]`/`[[` bindings are intentionally omitted from `snacks.lua` — see note in that file. Class navigation is the authoritative binding. |

---

## 14. Appendix

### Related Resources

- [lazy.nvim documentation](https://lazy.folke.io/)
- [snacks.nvim modules](https://github.com/folke/snacks.nvim)
- [blink.cmp documentation](https://cmp.saghen.dev/)
- [neovim-ayu colorscheme](https://github.com/atraides/neovim-ayu)
- [auto-dark-mode.nvim](https://github.com/f-person/auto-dark-mode.nvim)
- [mason.nvim registry](https://mason-registry.dev/)
- [SchemaStore catalog](https://www.schemastore.org/json/)
- [kickstart.nvim reference](https://github.com/nvim-lua/kickstart.nvim)
- [gh-actions.nvim](https://github.com/Hdoc1509/gh-actions.nvim)
- [gh-actions-language-server Mason package](https://github.com/mason-org/mason-registry/blob/main/packages/gh-actions-language-server/package.yaml)
- [GitHub Actions language server (official)](https://github.com/actions/languageservices/tree/main)
- [diffview.nvim fork (dlyongemallo)](https://github.com/dlyongemallo/diffview.nvim)
- [flash.nvim](https://github.com/folke/flash.nvim)
- [treesj](https://github.com/Wansmer/treesj)
- [mini.surround](https://github.com/echasnovski/mini.surround)
- [noice.nvim](https://github.com/folke/noice.nvim)
- [conform.nvim](https://github.com/stevearc/conform.nvim)

### Repository Structure (final)

```
github.com/atraides/ssnvim
├── init.lua
├── CHANGELOG.md
├── .cz.toml
├── lua/
│   ├── config/
│   │   ├── init.lua
│   │   ├── options.lua
│   │   ├── keymaps.lua
│   │   └── autocmds.lua
│   └── plugins/
│       ├── init.lua        (empty)
│       ├── ui.lua
│       ├── snacks.lua
│       ├── editor.lua
│       ├── git.lua
│       ├── treesitter.lua
│       ├── lsp.lua
│       ├── completion.lua
│       ├── formatting.lua
│       └── linting.lua
├── lazy-lock.json
├── .gitignore
├── README.md
└── .claude/
    └── PRD.md             ← this document
```

### Build Sequence Summary

```
Phase 1: Foundation       → init.lua, options, keymaps, autocmds
Phase 2: Look & Feel      → neovim-ayu, auto-dark-mode, lualine, noice, todo-comments
Phase 3: Navigation & Git → snacks (picker/lazygit/terminal/gh/explorer), oil,
                            which-key, gitsigns, diffview, flash, treesj, mini.surround
Phase 4: Treesitter       → nvim-treesitter + textobjects + gh-actions.nvim
Phase 5: LSP              → mason + lspconfig + SchemaStore + all servers
Phase 6: Completion       → blink.cmp + copilot
Phase 7: Format/Lint      → conform + nvim-lint
Phase 8: Polish           → docs, CHANGELOG, .cz.toml, checkhealth, startup time, lockfile
Phase 9: GitHub Actions   → gh_actions_ls, actionlint, gh-actions.nvim, yaml.github-actions ft
```
