# Feature: Phase 4 — Treesitter

The following plan should be complete, but validate the nvim-treesitter setup API and parser names before implementing. Pay special attention to the `config = function()` pattern (required for treesitter — opts table is not used), the correct fold expression for Neovim 0.11+, and the `build = ":TSUpdate"` hook.

## Feature Description

Add `nvim-treesitter` to ssnvim, enabling accurate syntax highlighting (replacing regex-based `ft` highlighting), treesitter-aware indentation, and incremental selection by syntax node. Installs parsers for all languages in the user's stack: Python, Go, bash, YAML, Helm, JSON, Lua, Markdown, and Dockerfile. Also updates the fold method in `options.lua` to use the treesitter expression — folds remain open by default.

## User Story

As a developer working across Python, Go, bash, YAML, and Helm daily, I want syntax highlighting that understands the grammar of each language, so that code structure is visually clear and I can expand/shrink selections by syntax node rather than by manual text objects.

## Problem Statement

Phases 1–3 use Neovim's built-in regex-based `ft` highlighting. This is inaccurate for edge cases (multi-line strings, nested structures, Helm Go-template expressions inside YAML). There is no way to select a syntax node and expand it to its parent without a treesitter-backed operator. The fold method is `manual`, so no folds exist at all.

## Solution Statement

Create `lua/plugins/treesitter.lua` with a single `nvim-treesitter/nvim-treesitter` spec. Enable `highlight`, `indent`, and `incremental_selection` modules. Install 10 parsers covering the full language stack. Update `lua/config/options.lua` to switch folds to treesitter-expression mode (folding stays disabled by default via `foldenable = false`).

## Feature Metadata

**Feature Type**: New Capability
**Estimated Complexity**: Low
**Primary Systems Affected**: `lua/plugins/treesitter.lua` (new), `lua/config/options.lua` (small edit)
**Dependencies**: nvim-treesitter/nvim-treesitter

---

## CONTEXT REFERENCES

### Relevant Codebase Files — READ BEFORE IMPLEMENTING

- `lua/plugins/ui.lua` (full file) — canonical reference for lazy.nvim spec comment style (`── Title ──` headers), `config = function(_, opts)` pattern, and no-globals rule. Mirror this style exactly.
- `lua/config/options.lua` (lines 53–55) — the two fold options to update: `foldmethod = "manual"` → `"expr"`, add `foldexpr`. `foldenable = false` stays as-is.
- `lua/plugins/editor.lua` (lines 1–17) — example of `event =` based lazy loading (`BufReadPre`). Treesitter uses `BufReadPost` + `BufNewFile` — similar pattern.
- `init.lua` (lines 32–37) — `spec = { { import = "plugins" } }` auto-picks up any new file in `lua/plugins/`. No changes needed to `init.lua`.
- `.claude/PRD.md` (§11, Phase 4) — authoritative parser list and acceptance criteria: "Helm template — `{{ .Values.image.tag }}` highlights as a Go template expression, surrounding YAML highlights as YAML."

### New Files to Create

- `lua/plugins/treesitter.lua` — single nvim-treesitter spec

### Files to Modify

- `lua/config/options.lua` — update fold block (lines 53–55): change `foldmethod` to `"expr"`, add `foldexpr`

---

## ARCHITECTURE DECISIONS

### Why `config = function()` instead of `opts = {}`

`nvim-treesitter` requires `require("nvim-treesitter.configs").setup({...})` — it does not use a standard `plugin.setup()` call that lazy.nvim's `opts` table would invoke. Using `opts` alone will silently do nothing. Always use `config = function()`.

### Fold expression: plugin vs native

Neovim 0.10+ ships a native treesitter fold expression: `v:lua.vim.treesitter.foldexpr()`. The plugin also provides `nvim_treesitter#foldexpr()`. For Neovim 0.11+ (this config's target), prefer the **native** expression — it has no external dependency and is the future-proof choice. The PRD mentioned the plugin function as a placeholder; use the native one instead.

### Event: `BufReadPost` + `BufNewFile`

`BufReadPost` loads treesitter for files opened from disk; `BufNewFile` covers new, unsaved buffers. Together they cover all real-world entry points. This is the standard nvim-treesitter lazy-load event pair.

### Parser: `helm` vs `gotmpl`

The treesitter parser for Helm templates is named `helm` in the nvim-treesitter registry (it bundles a combined YAML + Go-template grammar). Do NOT use `gotmpl` — it exists but does not produce the combined Helm highlighting.

### Incremental selection keymaps

`<CR>` to start/expand selection, `<BS>` to shrink. These are conventional for treesitter incremental selection and do not conflict with any existing ssnvim keymap.

---

## IMPLEMENTATION PLAN

### Phase 1: New plugin file

Create `lua/plugins/treesitter.lua` with the full spec.

### Phase 2: Options update

Edit `lua/config/options.lua` fold block to use treesitter-expression folding.

---

## STEP-BY-STEP TASKS

### CREATE `lua/plugins/treesitter.lua`

- **IMPLEMENT**: Return a single-element table containing the nvim-treesitter spec.
- **PATTERN**: Comment header style from `lua/plugins/ui.lua` — `── Section title ──` format with aligned dashes.
- **PLUGIN**: `"nvim-treesitter/nvim-treesitter"`
- **BUILD**: `build = ":TSUpdate"` — runs after install/update to compile parsers. Required for binary grammar files to be in sync with the plugin version.
- **EVENT**: `event = { "BufReadPost", "BufNewFile" }` — lazy-loads but covers all file-open cases.
- **CONFIG**: `config = function()` — call `require("nvim-treesitter.configs").setup({...})` inside.
- **PARSERS** (`ensure_installed`): `"python"`, `"go"`, `"gomod"`, `"bash"`, `"yaml"`, `"helm"`, `"json"`, `"lua"`, `"markdown"`, `"markdown_inline"`, `"dockerfile"` — 11 entries. `markdown_inline` is a separate parser required for inline code/bold/italic inside markdown blocks; always install alongside `markdown`.
- **HIGHLIGHT**: `highlight = { enable = true }` — replaces Neovim's regex ft highlighting.
- **INDENT**: `indent = { enable = true }` — enables `=` operator to indent by treesitter grammar.
- **INCREMENTAL SELECTION**:
  ```lua
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = "<CR>",   -- start selection on current node
      node_incremental  = "<CR>",   -- expand to parent node
      node_decremental  = "<BS>",   -- shrink to child node
      scope_incremental = false,    -- disable scope expansion (not needed for MVP)
    },
  }
  ```
- **GOTCHA**: Do not set `auto_install = true` — it silently downloads parsers for every filetype encountered, including ones not in the stack. Use `ensure_installed` instead for explicit control.
- **VALIDATE**: `nvim --headless -c "TSInstallInfo" -c "qa"` — lists parser install status (no errors).

### UPDATE `lua/config/options.lua` — fold block

- **LOCATION**: Lines 53–55 (the `── Folds ──` block).
- **REMOVE**: `vim.opt.foldmethod = "manual"` and its comment about Phase 4 override.
- **ADD**:
  ```lua
  vim.opt.foldmethod = "expr"                              -- treesitter-expression folding
  vim.opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"  -- native Neovim 0.10+ fold expr
  ```
- **KEEP**: `vim.opt.foldenable = false` unchanged — folds are available but all open by default.
- **UPDATE COMMENT**: Change the comment from `(treesitter overrides in Phase 4)` to reflect that this is now active.
- **GOTCHA**: `foldmethod = "expr"` causes Neovim to evaluate `foldexpr` on every line when treesitter hasn't loaded yet (e.g., in the dashboard buffer). This is safe — `vim.treesitter.foldexpr()` returns `"0"` gracefully for buffers with no treesitter parser, so no errors occur.
- **VALIDATE**: Open a Python file with a function — `:set foldmethod?` should return `expr`.

---

## VALIDATION COMMANDS

### Level 1: Syntax

```bash
# Check Lua syntax on both modified files (lua-ls not yet installed; use luacheck if available)
nvim --headless -c "luafile lua/plugins/treesitter.lua" -c "qa" 2>&1 || true
```

### Level 2: Plugin Load

```bash
# Start Neovim headless — lazy will detect the new spec and report any load errors
nvim --headless -c "Lazy check" -c "qa" 2>&1
```

### Level 3: Parser Install

Inside Neovim after first launch:
```
:TSInstallInfo
```
All 11 parsers in `ensure_installed` should show `[installed]`.

### Level 4: Startup Time

```bash
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
```
Goal: still < 100ms (treesitter loads lazily on `BufReadPost`; startup time should not regress).

### Level 5: Manual Validation

1. Open a Python file: `:set filetype?` → `python`; strings, keywords, and comments should highlight correctly.
2. Open a Helm template file (`templates/something.yaml`): Go template expressions `{{ .Values.foo }}` should be highlighted differently from surrounding YAML keys.
3. Press `<CR>` on a word in normal mode → enters visual selection of that node. Press `<CR>` again → expands to the containing expression. Press `<BS>` → shrinks back.
4. Run `:set foldmethod?` in any buffer → should return `expr`.

---

## ACCEPTANCE CRITERIA

- [ ] `lua/plugins/treesitter.lua` exists and is loaded by lazy.nvim without errors
- [ ] All 11 parsers install automatically on first launch (`ensure_installed`)
- [ ] `highlight`, `indent`, and `incremental_selection` modules are enabled
- [ ] Helm template files show combined Go-template + YAML highlighting
- [ ] `foldmethod=expr` is active; `foldenable=false` keeps folds open by default
- [ ] `<CR>` / `<BS>` incremental selection works in normal/visual mode
- [ ] Startup time remains < 100ms
- [ ] No errors in `:checkhealth nvim-treesitter`

---

## COMPLETION CHECKLIST

- [ ] `lua/plugins/treesitter.lua` created
- [ ] `lua/config/options.lua` fold block updated
- [ ] All 11 parsers listed in `ensure_installed`
- [ ] `config = function()` used (not `opts`)
- [ ] `build = ":TSUpdate"` present
- [ ] Native fold expression (`v:lua.vim.treesitter.foldexpr()`) used
- [ ] Manual validation steps confirmed
- [ ] Startup time verified < 100ms
- [ ] `lazy-lock.json` committed after `:Lazy sync`

---

## NOTES

- **Parser count**: 11 (not 10 as stated in the pre-plan discussion) — `markdown` and `markdown_inline` are always a pair; omitting `markdown_inline` causes broken inline code highlighting.
- **`auto_install = false`** (or omitted): Explicitly not set to `true`. Automatic parser installation downloads parsers for every file opened, including ones outside the stack. Keep install list explicit.
- **Snacks indent compatibility**: snacks.nvim indent guides fall back to indentation-level heuristic when treesitter is not loaded for a buffer. After Phase 4, snacks will automatically use treesitter scope where available — no configuration change needed.
- **Future Phase 5 note**: LSP and treesitter interact: treesitter provides `textDocument/semanticTokens` fallback when LSP semantic highlighting is not active. After Phase 5, LSP semantic tokens will layer on top of treesitter highlighting automatically via `nvim-lspconfig`.
- **Deferred**: `nvim-treesitter-context` (function context header) is explicitly out of scope per PRD §4. Do not add it here.
