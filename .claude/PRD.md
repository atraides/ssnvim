# ssnvim — Product Requirements Document

> **Version:** 1.0
> **Date:** 2026-03-29
> **Status:** Approved — ready for implementation

---

## 1. Executive Summary

ssnvim is a custom, hand-crafted Neovim configuration built from a clean slate in the spirit of `kickstart.nvim` — every line is explicit, commented, and intentionally chosen. Unlike distribution-based setups (LazyVim, AstroNvim), ssnvim is owned entirely by the user: no abstraction layers, no upstream opinions that can break customizations, no magic. It is designed to be a daily-driver editor for a developer whose primary stack spans Python, Go, bash/zsh, Kubernetes, Helm, and ArgoCD.

The configuration prioritizes a lean plugin surface area using modern, high-performance tools. `snacks.nvim` consolidates functionality that would otherwise require 4–5 separate plugins (fuzzy finder, dashboard, terminal, lazygit integration, indent guides, notifications). `blink.cmp` replaces the heavier `nvim-cmp` for completion. `oil.nvim` replaces traditional sidebar file trees. The result is a fast, minimal, opinionated environment that feels native rather than assembled.

The MVP delivers a fully functional development environment covering all languages in the user's stack, with automated LSP server installation, format-on-save, async linting, GitHub Copilot completion, and Rosé Pine theming that automatically tracks macOS dark/light mode. It is designed to be portable: a single `git clone` + `nvim` invocation on any machine bootstraps the entire environment.

**MVP Goal:** A working, minimal Neovim configuration that covers Python, Go, bash, YAML/Kubernetes, Helm, and ArgoCD editing with LSP, completion, formatting, linting, and Git integration — built incrementally so every piece is understood before the next is added.

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

| Attribute | Detail |
|---|---|
| **Vim experience** | 20+ years Vim, 2–3 months Neovim |
| **Keybinding knowledge** | Basics (hjkl, :wq, substitution) — wants to learn advanced, define own |
| **Programming languages** | Python (primary), Go (secondary), bash/zsh |
| **Python ecosystem** | FastAPI, Typer, SQLModel, Rich, Textual; pyenv/poetry/uv |
| **Infrastructure** | Kubernetes (multi-cluster, daily), Helm monorepos, ArgoCD Application YAML |
| **Git workflow** | lazygit as primary UI, commitizen for commit messages |
| **Terminal** | Ghostty — no tmux/zellij |
| **Philosophy** | TUI-first, avoids GUIs, learns by doing, starts minimal |

### Key Pain Points
- Existing AstroNvim setup is a black box — hard to debug, hard to modify
- Wants Helm/ArgoCD YAML to work properly (schema validation, correct LSP behavior)
- Needs Kubernetes context visible and switchable without leaving the editor
- GitHub Copilot must work within enterprise policy (Neovim is officially supported)
- Colorscheme must follow macOS dark/light mode automatically

---

## 4. MVP Scope

### Core Functionality

| Feature | Status |
|---|---|
| ✅ Sensible Neovim defaults (options, keymaps, autocmds) | In scope |
| ✅ lazy.nvim plugin manager with lockfile | In scope |
| ✅ Rosé Pine colorscheme (dawn=light, moon=dark) with OS auto-switch | In scope |
| ✅ lualine statusline with Kubernetes context component | In scope |
| ✅ snacks.nvim: picker (fuzzy find), dashboard, indent guides, notifier | In scope |
| ✅ snacks.nvim: lazygit float (`<leader>gg`) | In scope |
| ✅ snacks.nvim: floating terminal | In scope |
| ✅ oil.nvim file manager | In scope |
| ✅ which-key.nvim keybinding discovery | In scope |
| ✅ gitsigns.nvim for in-buffer git decorations | In scope |
| ✅ nvim-autopairs | In scope |
| ✅ nvim-treesitter + all required parsers | In scope |
| ✅ Helm filetype detection (templates/*.yaml → ft=helm) | In scope |
| ✅ mason.nvim + mason-lspconfig + nvim-lspconfig | In scope |
| ✅ LSP: pyright + ruff (Python) | In scope |
| ✅ LSP: gopls (Go) | In scope |
| ✅ LSP: bash-language-server (bash/zsh) | In scope |
| ✅ LSP: yaml-language-server + SchemaStore (K8s, Helm, ArgoCD schemas) | In scope |
| ✅ LSP: helm-ls (Helm charts) | In scope |
| ✅ LSP: lua-ls (Neovim config itself) | In scope |
| ✅ blink.cmp completion engine | In scope |
| ✅ GitHub Copilot via copilot.lua + blink-copilot | In scope |
| ✅ conform.nvim format-on-save | In scope |
| ✅ nvim-lint async linting | In scope |
| ✅ Python venv auto-detection (pyenv, poetry, uv) | In scope |
| ✅ README with install instructions and keybinding reference | In scope |

### Out of Scope (Future Phases)

| Feature | Status |
|---|---|
| ❌ DAP / step-through debugging (Python, Go) | Deferred |
| ❌ Bufferline / tab bar | Deferred (may not be needed) |
| ❌ noice.nvim cmdline/message UI overhaul | Deferred |
| ❌ nvim-treesitter-context (function context header) | Deferred |
| ❌ trouble.nvim project diagnostic list | Deferred |
| ❌ neogit / vim-fugitive Git UI | Deferred (lazygit covers needs) |
| ❌ diffview.nvim | Deferred |
| ❌ todo-comments.nvim | Deferred |
| ❌ kubectl/helm commands from within Neovim | Deferred |
| ❌ Ayu colorscheme (alternative) | Deferred |
| ❌ Test runner integration (pytest, go test) | Deferred |
| ❌ AI chat (Claude, Copilot Chat) within Neovim | Deferred |
| ❌ Remote/SSH editing | Deferred |

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

### US-5: Git workflow
> As a developer who relies on lazygit, I want to open lazygit as a floating window from within Neovim with a single keybinding, so that I can review, stage, and commit without switching applications.

- **Acceptance:** `<leader>gg` opens lazygit in a snacks float; closing it returns cursor to exact previous position.

### US-6: Multi-cluster Kubernetes context awareness
> As someone working with multiple Kubernetes clusters, I want the current kubectl context visible in the statusline, so that I always know which cluster I'm targeting.

- **Acceptance:** lualine displays the current `kubectl config current-context` value; updates when context changes.

### US-7: Keybinding discoverability
> As a developer still learning Neovim's advanced features, I want to see available keybindings when I press a leader-key prefix, so that I can discover and remember commands without consulting documentation.

- **Acceptance:** which-key shows a popup after `<leader>` pause; all custom keybindings are registered with descriptive labels.

### US-8: Appearance that respects the OS
> As someone who works in both light and dark environments, I want my colorscheme to automatically switch between Rosé Pine Dawn (light) and Rosé Pine Moon (dark) when macOS changes appearance, so that I never manually toggle the theme.

- **Acceptance:** Changing macOS appearance (System Settings → Appearance) updates Neovim's colorscheme within 1–2 seconds without any manual intervention.

---

## 6. Core Architecture & Patterns

### Architecture Overview

ssnvim follows a **module-per-concern** pattern inspired by kickstart.nvim's multi-file extension. The `init.lua` entry point is kept minimal — it only loads the `config` modules and bootstraps lazy.nvim. All plugin specifications live in `lua/plugins/`, grouped by functional area.

### Directory Structure

```
~/.config/nvim/          (symlinked or cloned from GitHub)
├── init.lua             # Entry: source config modules, bootstrap lazy.nvim
├── lua/
│   ├── config/
│   │   ├── options.lua  # vim.opt.* — editor behavior
│   │   ├── keymaps.lua  # Non-plugin keymaps (window nav, misc utilities)
│   │   └── autocmds.lua # Autocommands (Helm ftdetect, trailing whitespace, etc.)
│   └── plugins/
│       ├── ui.lua       # rose-pine, auto-dark-mode, lualine
│       ├── snacks.lua   # snacks.nvim (picker, dashboard, lazygit, terminal, indent, notifier)
│       ├── editor.lua   # oil.nvim, gitsigns, nvim-autopairs, which-key
│       ├── treesitter.lua  # nvim-treesitter + parsers
│       ├── lsp.lua      # mason + mason-lspconfig + nvim-lspconfig + SchemaStore
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
    opts = { ... },
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
    [".*/templates/.*%.tpl"]  = "helm",
    ["helmfile.*%.yaml"]      = "helm",
  },
})
```

**K8s context lualine component:**
```lua
local function k8s_context()
  local handle = io.popen("kubectl config current-context 2>/dev/null")
  if not handle then return "" end
  local result = handle:read("*a"):gsub("\n", "")
  handle:close()
  return result ~= "" and ("⎈ " .. result) or ""
end
```

**OS-aware colorscheme (auto-dark-mode.nvim):**
```lua
require("auto-dark-mode").setup({
  update_interval = 1000,
  set_dark_mode = function()
    vim.cmd("colorscheme rose-pine-moon")
  end,
  set_light_mode = function()
    vim.cmd("colorscheme rose-pine-dawn")
  end,
})
```

---

## 7. Feature Specifications

### 7.1 snacks.nvim — The Core Hub

snacks.nvim is configured as the primary multi-tool, replacing what would otherwise be 5+ plugins:

| Module | Keybinding | Description |
|---|---|---|
| `picker.files` | `<leader>ff` | Find files (respects .gitignore) |
| `picker.grep` | `<leader>fg` | Live grep across project |
| `picker.buffers` | `<leader>fb` | Switch open buffers |
| `picker.help` | `<leader>fh` | Search Neovim help |
| `picker.lsp_symbols` | `<leader>fs` | LSP document symbols |
| `picker.diagnostics` | `<leader>fd` | Project diagnostics |
| `lazygit` | `<leader>gg` | Open lazygit float |
| `terminal` | `<leader>tt` | Open floating terminal |
| `dashboard` | (startup) | Dashboard on `nvim` with no args |
| `notifier` | (automatic) | Replaces vim.notify |
| `indent` | (automatic) | Indent guides on all buffers |

### 7.2 LSP Configuration

Each language server is configured with explicit settings, not defaults:

**Python (pyright):**
- `pythonPath` auto-detected from active virtual environment
- `venvPath` set to `~/.pyenv/versions` and poetry/uv project directories
- `typeCheckingMode = "standard"` (not strict — practical balance)

**YAML (yamlls + SchemaStore):**
- `schemaStore.enable = false` (use SchemaStore.nvim catalog instead)
- `schemas = require("schemastore").yaml.schemas()` — auto-applies schemas for Kubernetes, Helm values, ArgoCD, GitHub Actions, Docker Compose, etc.
- Disabled for `helm` filetype files

**Helm (helm-ls):**
- Only attaches to `ft=helm` files
- `yamlls` explicitly excluded from Helm buffers

### 7.3 Completion Stack

```
blink.cmp
├── source: lsp        (primary — LSP completions)
├── source: copilot    (via blink-copilot — GitHub Copilot suggestions)
├── source: path       (filesystem paths)
├── source: buffer     (words from open buffers)
└── source: snippets   (blink.cmp built-in snippet support)
```

Copilot completions appear as a distinct source with lower priority than LSP. Copilot auth via `:Copilot auth` on first run.

### 7.4 Formatting (conform.nvim)

Format-on-save enabled for all configured filetypes:

| Filetype | Formatter | Notes |
|---|---|---|
| `python` | `ruff_format` | Replaces black; handles imports too |
| `go` | `goimports` | Manages imports + formats |
| `bash`, `zsh`, `sh` | `shfmt` | Shell script formatting |
| `yaml` | `yamlls` (LSP) | Via LSP formatting action |
| `lua` | `stylua` | For the config itself |
| `markdown` | `prettier` | Optional, for README etc. |

### 7.5 Linting (nvim-lint)

Async linting triggered on `BufWritePost` and `BufReadPost`:

| Filetype | Linter |
|---|---|
| `python` | `ruff` |
| `go` | `golangci-lint` |
| `bash`, `sh` | `shellcheck` |
| `yaml` | `yamllint` |

---

## 8. Technology Stack

### Core

| Component | Choice | Version |
|---|---|---|
| Editor | Neovim | 0.11+ (0.12 when stable) |
| Plugin manager | lazy.nvim | latest (pinned via lazy-lock.json) |
| Language | Lua | 5.1 (LuaJIT, bundled with Neovim) |

### Plugins

| Plugin | Version | Purpose |
|---|---|---|
| `folke/lazy.nvim` | latest | Plugin manager |
| `rose-pine/neovim` | latest | Primary colorscheme |
| `f-person/auto-dark-mode.nvim` | latest | macOS dark/light mode sync |
| `nvim-lualine/lualine.nvim` | latest | Statusline |
| `folke/snacks.nvim` | latest | Picker, dashboard, lazygit, terminal, indent, notifier |
| `stevearc/oil.nvim` | latest | File manager |
| `lewis6991/gitsigns.nvim` | latest | Git signs + hunk operations |
| `windwp/nvim-autopairs` | latest | Auto-close brackets/quotes |
| `folke/which-key.nvim` | latest | Keybinding discovery |
| `nvim-treesitter/nvim-treesitter` | latest | Syntax highlighting |
| `williamboman/mason.nvim` | latest | LSP/tool installer |
| `williamboman/mason-lspconfig.nvim` | latest | Mason ↔ lspconfig bridge |
| `neovim/nvim-lspconfig` | latest | LSP client configs |
| `b0o/schemastore.nvim` | latest | JSON/YAML schema catalog |
| `saghen/blink.cmp` | latest | Completion engine |
| `zbirenbaum/copilot.lua` | latest | GitHub Copilot |
| `fang2hou/blink-copilot` | latest | Copilot → blink.cmp bridge |
| `stevearc/conform.nvim` | latest | Formatter runner |
| `mfussenegger/nvim-lint` | latest | Async linter runner |

**Total plugin count: 19**

### Language Servers (installed by Mason)

| Server | Language |
|---|---|
| `pyright` | Python type checking |
| `ruff` | Python linting + formatting |
| `gopls` | Go |
| `goimports` | Go imports formatter |
| `golangci-lint` | Go multi-linter |
| `bash-language-server` | Bash/Zsh |
| `shellcheck` | Shell linting |
| `shfmt` | Shell formatting |
| `yaml-language-server` | YAML / Kubernetes / Helm values |
| `yamllint` | YAML linting |
| `helm-ls` | Helm templates |
| `lua-ls` | Lua (Neovim config) |
| `stylua` | Lua formatting |

### External Tools (assumed present on developer machines)

| Tool | Purpose |
|---|---|
| `lazygit` | Git TUI (opened via snacks.lazygit) |
| `commitizen` | Conventional commit messages |
| `kubectl` | Kubernetes CLI (context read for statusline) |
| `helm` | Helm CLI |
| `pyenv` | Python version + virtualenv management |
| `poetry` | Python dependency management |
| `uv` | Fast Python package manager |

---

## 9. Security & Configuration

### Authentication

- **GitHub Copilot:** Enterprise OAuth via `:Copilot auth` on first launch. Token stored in `~/.config/github-copilot/`. The enterprise subscription explicitly supports Neovim as an IDE.
- **No API keys** are stored in the config repository. All secrets remain in system-level credential stores.

### Sensitive Data Handling

- `lazy-lock.json` is committed — contains only public plugin commit hashes, no secrets.
- `.gitignore` excludes: `.luarc.json`, `*.log`, any file matching `*.env`.
- The `~/.kube/config` is read at runtime for the K8s context statusline component — never written or modified by the config.

### Portability Considerations

- All paths use `vim.fn.stdpath()` for cross-machine compatibility.
- Mason installs tools to `~/.local/share/nvim/mason/` — no system-level write access required.
- Python virtual environment detection uses relative paths and standard conventions — no hardcoded absolute paths.

---

## 10. Success Criteria

### MVP Definition

The MVP is complete when:

✅ `git clone <repo> ~/.config/nvim && nvim` fully bootstraps on a fresh machine without manual steps
✅ All 13 language servers install automatically via Mason on first launch
✅ Python files in a FastAPI project show pyright type errors and ruff lint diagnostics
✅ YAML files in a Kubernetes manifest directory show schema-validated completions
✅ Helm `templates/*.yaml` files are detected as `ft=helm` and use `helm-ls`, not `yamlls`
✅ `<leader>gg` opens lazygit as a floating window
✅ Rosé Pine switches automatically between dawn/moon when macOS appearance changes
✅ Current kubectl context appears in the statusline
✅ GitHub Copilot completions appear in blink.cmp alongside LSP completions
✅ Format-on-save runs for Python, Go, bash, and Lua files
✅ `<leader>` + pause shows which-key popup with all registered bindings
✅ `README.md` documents installation and all non-obvious keybindings

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

### Phase 1 — Foundation
**Goal:** Working Neovim with sensible defaults, no plugins.

✅ `init.lua` — bootstrap lazy.nvim, load config modules
✅ `lua/config/options.lua` — line numbers, tab settings, search, clipboard, sign column, etc.
✅ `lua/config/keymaps.lua` — window navigation, buffer navigation, misc utilities
✅ `lua/config/autocmds.lua` — Helm filetype detection, trailing whitespace trim, highlight on yank
✅ `.gitignore` and initial `README.md`
✅ First commit pushed to GitHub

**Validation:** `nvim` opens, `:set number?` shows `number`, Helm `.yaml` files detected correctly.

---

### Phase 2 — Look & Feel
**Goal:** Beautiful, informative UI baseline.

✅ `lua/plugins/ui.lua` — rose-pine + auto-dark-mode
✅ lualine with: mode, filename, git branch, diagnostics, K8s context, filetype, position
✅ `lua/plugins/snacks.lua` — dashboard, indent guides, notifier only (picker + lazygit in Phase 3)

**Validation:** Colorscheme switches on macOS appearance change; K8s context shows in statusline; dashboard appears on bare `nvim`.

---

### Phase 3 — Navigation & Git
**Goal:** Full file/code/project navigation.

✅ snacks.picker — files, grep, buffers, help, LSP symbols, diagnostics
✅ snacks.lazygit — `<leader>gg` float
✅ snacks.terminal — `<leader>tt` float
✅ oil.nvim — `-` key to open parent directory
✅ which-key — all keybindings registered with descriptions
✅ gitsigns — signs, hunk staging, blame
✅ nvim-autopairs

**Validation:** `<leader>ff` finds files; `<leader>gg` opens lazygit; `-` opens oil; `<leader>` shows which-key popup.

---

### Phase 4 — Treesitter
**Goal:** Correct syntax highlighting for all languages.

✅ nvim-treesitter with parsers: `python`, `go`, `gomod`, `bash`, `yaml`, `helm`, `json`, `lua`, `markdown`, `dockerfile`
✅ Verify Helm template files highlight correctly with both Go template and YAML

**Validation:** Open a Helm template — `{{ .Values.image.tag }}` highlights as a Go template expression, surrounding YAML highlights as YAML.

---

### Phase 5 — LSP
**Goal:** Full code intelligence for all languages.

✅ mason.nvim bootstrap and auto-install of all 13 tools
✅ nvim-lspconfig with server configs for: pyright, ruff, gopls, bash-language-server, yamlls, helm-ls, lua-ls
✅ SchemaStore.nvim integrated with yamlls
✅ yamlls explicitly disabled for `ft=helm` buffers
✅ Python venv auto-detection for pyenv, poetry, uv
✅ LSP keymaps: go-to-definition, hover, references, rename, code action, diagnostics

**Validation:** Open a FastAPI project — pyright shows types; open a K8s manifest — completions include all API fields; open a Helm template — helm-ls attaches, yamlls does not.

---

### Phase 6 — Completion
**Goal:** Fast, AI-assisted completion.

✅ blink.cmp configured with LSP, path, buffer, snippet sources
✅ copilot.lua installed and authenticated
✅ blink-copilot bridge configured
✅ Copilot ghost text / inline suggestions configured

**Validation:** In a Python file, Copilot suggestions appear; LSP completions appear; Tab/Enter accept. `:Copilot status` shows authenticated.

---

### Phase 7 — Formatting & Linting
**Goal:** Automatic code quality enforcement.

✅ conform.nvim format-on-save for: Python (ruff_format), Go (goimports), bash (shfmt), Lua (stylua)
✅ nvim-lint async linting for: Python (ruff), Go (golangci-lint), bash (shellcheck), YAML (yamllint)
✅ `<leader>cf` keymap for manual format trigger

**Validation:** Save a Python file with `import os` unused — ruff removes it; save a Go file — goimports runs; YAML with wrong indentation — yamllint marks it.

---

### Phase 8 — Polish & Documentation
**Goal:** Repo is complete, documented, and push-button installable.

✅ `README.md` — installation steps, prerequisites, keybinding reference
✅ All which-key groups labeled and organized
✅ `:checkhealth` passes with no errors
✅ `lazy-lock.json` committed
✅ Startup time verified < 100ms

**Validation:** Fresh clone on a second machine bootstraps fully without intervention.

---

## 12. Future Considerations

### Post-MVP Enhancements (Priority Order)

1. **DAP / Debugging** — `nvim-dap` + `nvim-dap-ui` + `nvim-dap-python` for FastAPI/Typer debugging when print/pdb becomes insufficient
2. **trouble.nvim** — Project-wide diagnostic list once the LSP setup is mature
3. **nvim-treesitter-context** — Function/class context header for navigating large files
4. **todo-comments.nvim** — Highlight and search TODO/FIXME/NOTE across projects
5. **Ayu colorscheme** — As a second theme option alongside Rosé Pine
6. **kubectl integration** — Consider `kubectl.nvim` or custom terminal commands for K8s operations
7. **Test runner** — `neotest` with pytest and Go test adapters
8. **AI chat** — Claude or Copilot Chat integration within Neovim
9. **diffview.nvim** — Rich side-by-side diffs as a complement to lazygit
10. **noice.nvim** — Full cmdline/message UI overhaul (deferred — can be complex to debug)

### Integration Opportunities

- **ArgoCD CLI** — `argocd` commands via snacks.terminal for quick app sync/status
- **Helm chart testing** — Pre-commit hooks with `chart-testing` (ct) for Helm monorepos
- **Remote/SSH editing** — Neovim's built-in `scp://` or `oil-ssh` for remote file editing

---

## 13. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Helm/YAML LSP conflict** — `yamlls` and `helm-ls` both attaching to Helm templates, causing noise/errors | High | High | Explicit `filetypes` config on yamlls to exclude `helm` ft; filetype detection autocmd runs before LSP attach |
| **Copilot enterprise policy** — enterprise admin changes policy and blocks Neovim | Low | High | Document the current allowed method; keep `copilot.lua` in its own file so it can be disabled cleanly without touching other config |
| **snacks.nvim breaking changes** — Folke's active development means APIs shift | Medium | Medium | Commit `lazy-lock.json`; update intentionally, not automatically; read changelog before `<leader>lu` (lazy update) |
| **Python venv not detected** — pyright picks up wrong Python or none, making completions useless | Medium | High | Explicit `pythonPath` logic covering pyenv, poetry, and uv conventions; document manual override with `.pyrightconfig.json` |
| **K8s context lualine component slow** — `io.popen("kubectl ...")` blocks on every statusline redraw | Medium | Medium | Cache the result; invalidate only on `BufEnter`/`FocusGained`; use `vim.fn.system()` async variant or read `~/.kube/config` directly via Lua |

---

## 14. Appendix

### Related Resources

- [lazy.nvim documentation](https://lazy.folke.io/)
- [snacks.nvim modules](https://github.com/folke/snacks.nvim)
- [blink.cmp documentation](https://cmp.saghen.dev/)
- [Rosé Pine for Neovim](https://github.com/rose-pine/neovim)
- [mason.nvim registry](https://mason-registry.dev/)
- [SchemaStore catalog](https://www.schemastore.org/json/)
- [kickstart.nvim reference](https://github.com/nvim-lua/kickstart.nvim)
- [auto-dark-mode.nvim](https://github.com/f-person/auto-dark-mode.nvim)

### Repository Structure (final)

```
github.com/<user>/ssnvim
├── init.lua
├── lua/
│   ├── config/
│   │   ├── options.lua
│   │   ├── keymaps.lua
│   │   └── autocmds.lua
│   └── plugins/
│       ├── ui.lua
│       ├── snacks.lua
│       ├── editor.lua
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
Phase 1: Foundation    → init.lua, options, keymaps, autocmds
Phase 2: Look & Feel   → rose-pine, auto-dark-mode, lualine, snacks (UI)
Phase 3: Navigation    → snacks (picker/lazygit/terminal), oil, which-key, gitsigns
Phase 4: Treesitter    → nvim-treesitter + all parsers
Phase 5: LSP           → mason + lspconfig + SchemaStore + all servers
Phase 6: Completion    → blink.cmp + copilot
Phase 7: Format/Lint   → conform + nvim-lint
Phase 8: Polish        → docs, checkhealth, startup time, lockfile
```
