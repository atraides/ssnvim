# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

ssnvim is a hand-crafted Neovim configuration built from a clean slate in the spirit of `kickstart.nvim`. Every file is explicitly written and commented — no distribution black-boxes, no inherited opinions. It is the daily-driver editor for a developer whose stack spans Python, Go, bash/zsh, Kubernetes, Helm, and ArgoCD.

The configuration prioritises a lean plugin surface (19 plugins) using modern, fast implementations: `lazy.nvim` for plugin management, `blink.cmp` for completion, `snacks.nvim` as a multi-tool hub (picker, dashboard, lazygit, terminal, indent guides, notifications), and `oil.nvim` for file management. It is fully portable: `git clone` + `nvim` bootstraps the entire environment on any machine via Mason auto-installation.

Full requirements and decisions are in `.claude/PRD.md`.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Neovim 0.11+ | The editor; Lua 5.1 (LuaJIT) as the config language |
| `lazy.nvim` | Plugin manager; lazy-loading; lockfile (`lazy-lock.json`) |
| `snacks.nvim` | Multi-tool hub: picker, dashboard, lazygit, terminal, gh, explorer, indent, notifier, zen, scratch |
| `blink.cmp` | Completion engine (replaces nvim-cmp; pre-built Rust binary) |
| `copilot.lua` + `blink-copilot` | GitHub Copilot (enterprise subscription) |
| `nvim-lspconfig` + `mason.nvim` | LSP client config + automated server installation |
| `mason-lspconfig.nvim` | Mason ↔ lspconfig bridge (automatic_enable) |
| `conform.nvim` | Format-on-save runner |
| `nvim-lint` | Async linting |
| `nvim-treesitter` + `nvim-treesitter-textobjects` | Syntax highlighting, text objects, and motions |
| `gh-actions.nvim` | GitHub Actions `${{ }}` expression treesitter grammar |
| `atraides/neovim-ayu` | Colorscheme (ayu-mirage=dark, ayu-light=light) |
| `auto-dark-mode.nvim` | Switches ayu variant with macOS appearance (polls every 1s) |
| `lualine.nvim` | Statusline (mode, branch, filename, diff, diagnostics, LSP status) |
| `noice.nvim` | Enhanced cmdline, message, and notification UI |
| `todo-comments.nvim` | Highlight and search TODO/FIXME/NOTE/HACK/PERF comments |
| `mini.icons` | File and other icons (replaces nvim-web-devicons as icon provider) |
| `oil.nvim` | File manager (filesystem-as-buffer) |
| `gitsigns.nvim` | In-buffer git decorations, hunk operations, and blame |
| `diffview.nvim` | Rich side-by-side diffs and file history (`dlyongemallo` fork) |
| `flash.nvim` | Enhanced motion and search with jump labels |
| `treesj` | Split/join code blocks (treesitter-aware) |
| `which-key.nvim` | Keybinding discovery popup |
| `mini.surround` | Surround text objects (sa/sd/sr/sf/sF/sh) |
| `mini.pairs` | Auto-close brackets and quotes (replaces nvim-autopairs) |
| `schemastore.nvim` | YAML schema catalog (K8s, Helm, ArgoCD CRDs) |

---

## Project Structure

```
ssnvim/
├── init.lua                    # Entry point: bootstrap lazy.nvim, require config modules
├── lua/
│   ├── config/
│   │   ├── init.lua            # Loads options, keymaps, autocmds
│   │   ├── options.lua         # vim.opt.* — editor behaviour
│   │   ├── keymaps.lua         # Non-plugin keymaps (window/buffer nav, utilities)
│   │   └── autocmds.lua        # Autocommands (Helm/GHA ftdetect, whitespace trim, etc.)
│   └── plugins/
│       ├── init.lua            # Empty placeholder (returns {})
│       ├── ui.lua              # neovim-ayu, auto-dark-mode, lualine, noice, todo-comments, mini.icons
│       ├── snacks.lua          # snacks.nvim: picker, dashboard, lazygit, terminal, gh, explorer, etc.
│       ├── editor.lua          # oil.nvim, which-key, flash, treesj, mini.surround, mini.pairs
│       ├── git.lua             # gitsigns.nvim, diffview.nvim
│       ├── treesitter.lua      # nvim-treesitter + textobjects + gh-actions.nvim
│       ├── lsp.lua             # mason + mason-lspconfig + nvim-lspconfig + SchemaStore
│       ├── completion.lua      # blink.cmp + copilot.lua + blink-copilot
│       ├── formatting.lua      # conform.nvim
│       └── linting.lua         # nvim-lint
├── lazy-lock.json              # Committed — pin plugin versions for reproducibility
├── .gitignore
├── README.md
└── .claude/
    ├── PRD.md                  # Full product requirements and architectural decisions
    └── CLAUDE-template.md
```

---

## Architecture

### Module-per-concern pattern

`init.lua` is kept minimal — it bootstraps `lazy.nvim` and sources the three `config/` modules. All plugin specifications live in `lua/plugins/` as separate files, each returning a list of lazy.nvim plugin specs.

```lua
-- init.lua pattern (illustrative)
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")   -- bootstraps lazy.nvim, loads lua/plugins/**
```

### Plugin spec pattern

Every plugin is a lazy.nvim spec. Configuration goes in `opts = {}` (preferred) or `config = function() end` for complex setups. Keys and commands are declared inside the spec for automatic lazy-loading.

```lua
-- lua/plugins/editor.lua
return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = { ... },
  },
}
```

### Keybinding convention

- Leader key: `<Space>`
- All custom bindings registered through `which-key.nvim` with a `desc` string
- Binding groups: `<leader>f` (find/pick), `<leader>g` (git), `<leader>l` (LSP), `<leader>t` (terminal — unused; terminal lives under `<leader>f`), `<leader>c` (code actions), `<leader>s` (search), `<leader>u` (UI toggles), `<leader>b` (buffer)
- LSP bindings use `LspAttach` autocmd so they only exist in buffers with an active LSP client
- `gd`, `gD`, `gI`, `grf`, `gy` are defined globally in `snacks.lua` as picker-based navigation; buffer-local LspAttach versions of `gd`/`gD`/`gI` are shadowed by the global snacks bindings in practice

---

## Code Patterns

### Naming conventions

- Lua files: `snake_case.lua`
- Plugin spec files named by function area: `ui.lua`, `editor.lua`, `lsp.lua`, etc.
- Local variables: `snake_case`
- No global variables — everything scoped to module or function

### Options (options.lua)

```lua
-- Group related options with a comment header
-- Navigation
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
```

### Keymaps (keymaps.lua)

```lua
-- Always include desc for which-key integration
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- LSP-specific keymaps go in an LspAttach autocmd, not keymaps.lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to definition" })
  end,
})
```

### Autocommands (autocmds.lua)

```lua
-- Group related autocmds in named augroups
local group = vim.api.nvim_create_augroup("ssnvim_helm", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  pattern = { "*/templates/*.yaml", "*/templates/*.tpl", "helmfile*.yaml" },
  callback = function() vim.bo.filetype = "helm" end,
})
```

### Avoiding common mistakes

- **Never use `require()` at module top-level inside a lazy.nvim `opts` table** — use `config = function()` instead
- **Helm vs YAML LSP conflict**: `yamlls` must have `filetypes` set to exclude `helm`; `helm-ls` must only attach to `ft=helm`
- **K8s statusline component**: cache the `kubectl` context result; do not call `io.popen` on every statusline redraw
- **Python venv**: always configure `pyright` with explicit `venvPath` settings; do not rely on PATH alone
- **mini.nvim org**: plugin specs use `nvim-mini/mini.surround`, `nvim-mini/mini.pairs`, `nvim-mini/mini.icons` — do not change to `echasnovski/` without verifying lazy.nvim resolves the repo correctly

---

## Validation

Run these checks before committing:

```bash
# Start Neovim and check plugin health
nvim --headless -c "checkhealth" -c "qa"

# Measure startup time (goal: < 100ms)
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log

# Verify lazy-lock.json is up to date (run inside Neovim)
# :Lazy sync   → update all plugins
# :Lazy log    → review changes
# then commit lazy-lock.json

# Lint this config's Lua files (once lua-ls is set up)
# :lua vim.lsp.buf.format()  inside any lua file
```

Inside Neovim after a fresh install:

```
:checkhealth lazy       → plugin manager healthy
:checkhealth mason      → all tools installed
:Mason                  → all servers green
:Lazy                   → no errors
:Copilot status         → authenticated
```

---

## Key Files

| File | Purpose |
|---|---|
| `init.lua` | Entry point — touch only to add new top-level requires |
| `lua/config/options.lua` | All `vim.opt.*` settings |
| `lua/config/keymaps.lua` | Non-plugin global keymaps |
| `lua/config/autocmds.lua` | Filetype detection (Helm, GitHub Actions), QoL autocmds |
| `lua/plugins/lsp.lua` | Most complex file — LSP server configs, SchemaStore, venv detection |
| `lua/plugins/snacks.lua` | Central navigation hub — picker, lazygit, terminal, gh, explorer |
| `lua/plugins/completion.lua` | blink.cmp + Copilot wiring |
| `lua/plugins/git.lua` | gitsigns (hunk ops, blame) + diffview (diff views, file history) |
| `lazy-lock.json` | **Always commit** — pins plugin versions for reproducibility |
| `.claude/PRD.md` | Full requirements, plugin list, build phases, risk register |

---

## Build Phases

The config is built incrementally. Each phase is complete and functional before the next begins.

| Phase | Files | Status |
|---|---|---|
| 1 — Foundation | `init.lua`, `config/options.lua`, `config/keymaps.lua`, `config/autocmds.lua` | ✅ Complete |
| 2 — Look & Feel | `plugins/ui.lua` (neovim-ayu, auto-dark-mode, lualine, noice, todo-comments) | ✅ Complete |
| 3 — Navigation | `plugins/snacks.lua` (picker, lazygit, terminal, gh, explorer), `plugins/editor.lua` (oil, which-key, flash, treesj, mini.surround, mini.pairs), `plugins/git.lua` (gitsigns, diffview) | ✅ Complete |
| 4 — Treesitter | `plugins/treesitter.lua` (nvim-treesitter + textobjects + gh-actions.nvim) | ✅ Complete |
| 5 — LSP | `plugins/lsp.lua` | ✅ Complete |
| 6 — Completion | `plugins/completion.lua` | ✅ Complete |
| 7 — Format/Lint | `plugins/formatting.lua`, `plugins/linting.lua` | ✅ Complete |
| 8 — Polish | README, checkhealth, startup time, lockfile commit | ✅ Complete |
| 9 — GitHub Actions | `yaml.github-actions` ft, `gh_actions_ls`, `actionlint`, `gh-actions.nvim` | ✅ Complete |

---

## Language Server Reference

All installed and configured via Mason. Do not install manually.

| Server | Filetype | Role |
|---|---|---|
| `pyright` | python | Type checking, completions |
| `ruff` | python | Linting + formatting (replaces black/flake8/isort) |
| `gopls` | go | All Go intelligence |
| `goimports` | go | Import management + formatting |
| `golangci-lint` | go | Multi-linter runner |
| `bash-language-server` | bash, sh, zsh | Shell completions and hover |
| `shellcheck` | bash, sh | Shell linting |
| `shfmt` | bash, sh | Shell formatting |
| `yaml-language-server` | yaml (NOT helm) | K8s manifests, ArgoCD YAML, Helm values |
| `yamllint` | yaml | YAML linting |
| `helm-ls` | helm | Helm template intelligence |
| `lua-ls` | lua | Config file intelligence |
| `stylua` | lua | Lua formatting |

---

## On-Demand Context

| Topic | File |
|---|---|
| Full requirements, plugin list, risk register | `.claude/PRD.md` |
| User profile, workflow, and tool preferences | `~/.claude/projects/-Users-atraides-Develop-ssnvim/memory/user_profile.md` |
| Architectural decisions and plugin choices | `~/.claude/projects/-Users-atraides-Develop-ssnvim/memory/project_ssnvim.md` |

---

## Notes

- **Owner:** This is a personal config — no team conventions to follow. Every decision is documented in the PRD or in file comments.
- **Portability target:** macOS (Ghostty terminal). Linux compatibility is desirable but not required.
- **Copilot:** Enterprise subscription. Auth via `:Copilot auth` on first launch. Do not add Copilot API keys to any file in this repo.
- **Helm/YAML conflict:** The single most important correctness concern. Always verify that `yamlls` does NOT attach to `ft=helm` buffers and `helm-ls` DOES.
- **lazy-lock.json:** Always commit after intentional updates (`:Lazy sync`). Never commit after an accidental `:Lazy update` you didn't review.
- **Startup time goal:** < 100ms measured with `--startuptime`. Verify after adding new plugins.
- **Incremental discipline:** Do not add a plugin without a felt need. The current 19-plugin list covers all MVP requirements.
