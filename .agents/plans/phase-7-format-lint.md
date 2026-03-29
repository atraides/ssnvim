# Feature: Phase 7 — Format / Lint (conform.nvim + nvim-lint)

The following plan should be complete, but validate codebase patterns and documentation before implementing.
Pay special attention to linter name spelling in nvim-lint (underscores, not hyphens) and the
conform.nvim `lsp_format` API (renamed from `lsp_fallback` in v7+).

## Feature Description

Add format-on-save and async linting to ssnvim via `conform.nvim` (formatter runner) and
`mfussenegger/nvim-lint` (linting runner). Together they replace the need for LSP-only
formatting and bring shellcheck/golangci-lint/yamllint diagnostics as nvim diagnostics without
requiring a full LSP server for each tool.

## User Story

As a developer working across Python, Go, Lua, shell, and YAML daily,
I want files formatted on save and linting errors surfaced as diagnostics without blocking typing,
so that code quality is maintained automatically without manual `:Format` invocations.

## Problem Statement

Phase 6 adds completions but no format-on-save and no dedicated linting runner. `vim.lsp.buf.format`
in `lsp.lua` only reaches servers that support formatting; it cannot run standalone tools like
`goimports`, `stylua`, `shfmt`, or invoke linters like `shellcheck` and `golangci-lint`.

## Solution Statement

Two new files, zero edits to existing files. `lua/plugins/formatting.lua` wires `conform.nvim`
with per-filetype formatters and format-on-save. `lua/plugins/linting.lua` wires `nvim-lint` with
per-filetype linters and a `BufWritePost`/`BufReadPost` autocmd to trigger linting async.
All required binaries are already installed by mason.nvim in `lsp.lua`'s mason config function.

## Feature Metadata

**Feature Type**: New Capability
**Estimated Complexity**: Low
**Primary Systems Affected**: `lua/plugins/formatting.lua` (new), `lua/plugins/linting.lua` (new)
**Dependencies**: `stevearc/conform.nvim`, `mfussenegger/nvim-lint`

---

## CONTEXT REFERENCES

### Relevant Codebase Files — MUST READ BEFORE IMPLEMENTING

- `lua/plugins/editor.lua` (lines 82–96) — which-key registers `{ "<leader>c", group = "code" }`.
  Manual format keymap `<leader>cf` belongs in this group. The group label is already declared;
  just add the keymap inside the conform.nvim spec's `keys = {}` table.
- `lua/plugins/lsp.lua` (lines 103–108) — `<leader>lf` is already bound to `vim.lsp.buf.format`.
  Do NOT duplicate it. `<leader>cf` (conform) and `<leader>lf` (LSP) serve different purposes:
  conform runs standalone tools; LSP format calls the server's formatter.
- `lua/plugins/lsp.lua` (lines 20–44) — Mason non-LSP tool install list. All formatters and
  linters needed by Phase 7 are already listed here: `goimports`, `shfmt`, `stylua`,
  `golangci-lint`, `shellcheck`, `yamllint`. No new mason entries needed.
- `lua/plugins/treesitter.lua` (lines 15–65) — Reference for `config = function()` pattern.
  nvim-lint requires this pattern because it needs to set `lint.linters_by_ft` imperatively
  and register an autocmd. `opts = {}` alone does not work for nvim-lint.
- `lua/plugins/editor.lua` (lines 6–17) — `oil.nvim` shows `lazy = false` + `keys = {}` pattern.
  conform.nvim uses a similar eager-ish load but via `event` instead of `lazy = false`.
- `lua/config/autocmds.lua` (lines 16–38) — Augroup naming convention: `ssnvim_{name}`.
  nvim-lint's lint autocmd augroup must follow: `ssnvim_lint`.
- `init.lua` (line 34) — `defaults = { lazy = true }`. Both new plugins need explicit `event`
  or `cmd` triggers — they must not load at startup.

### New Files to Create

- `lua/plugins/formatting.lua` — conform.nvim spec: formatters_by_ft, format_on_save, manual keymap
- `lua/plugins/linting.lua` — nvim-lint spec: linters_by_ft, BufWritePost/BufReadPost autocmd

### Files to Edit

None. Both files are greenfield.

### Relevant Documentation — READ BEFORE IMPLEMENTING

- [conform.nvim README — Installation](https://github.com/stevearc/conform.nvim#installation)
  - Section: lazy.nvim spec, `event = "BufWritePre"`, `cmd = "ConformInfo"`
- [conform.nvim — Options Reference](https://github.com/stevearc/conform.nvim/blob/master/doc/conform.txt)
  - Section: `formatters_by_ft`, `format_on_save`, `lsp_format` option values
  - **CRITICAL**: As of v7, `lsp_fallback` is deprecated. Use `lsp_format = "fallback"` instead.
    Both `format_on_save` table and the `require("conform").format()` call accept `lsp_format`.
- [conform.nvim — Formatters list](https://github.com/stevearc/conform.nvim/blob/master/doc/formatter_options.md)
  - Verify exact formatter names: `ruff_format`, `goimports`, `stylua`, `shfmt`
- [nvim-lint README](https://github.com/mfussenegger/nvim-lint#usage)
  - Section: `linters_by_ft` table, `try_lint()`, autocmd setup pattern
- [nvim-lint — Linters list](https://github.com/mfussenegger/nvim-lint#available-linters)
  - **CRITICAL**: Verify exact linter names — they match the filename in `lua/lint/linters/`:
    - golangci-lint → `golangci_lint` (underscore, no hyphen)
    - shellcheck → `shellcheck`
    - yamllint → `yamllint`

---

## PATTERNS TO FOLLOW

### Event-based lazy loading (from editor.lua, lsp.lua)

```lua
-- conform.nvim: load just before write
event = { "BufWritePre" }
cmd   = { "ConformInfo" }   -- also load when :ConformInfo is called

-- nvim-lint: load after read (to lint existing files) and after write (to lint changes)
event = { "BufWritePost", "BufReadPost" }
```

### keys = {} for manual keymap (from editor.lua oil.nvim, snacks.lua)

```lua
keys = {
  {
    "<leader>cf",
    function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
    desc = "Format buffer",
  },
},
```

### opts = {} vs config = function()

```lua
-- conform.nvim: supports opts = {} (lazy.nvim calls setup automatically)
opts = {
  formatters_by_ft = { ... },
  format_on_save   = { ... },
}

-- nvim-lint: MUST use config = function() — needs imperative assignment + autocmd
-- opts = {} does NOT work; nvim-lint has no setup() that accepts linters_by_ft
config = function()
  local lint = require("lint")
  lint.linters_by_ft = { ... }
  vim.api.nvim_create_autocmd(...)
end
```

### Augroup naming convention (from autocmds.lua)

```lua
local lint_group = vim.api.nvim_create_augroup("ssnvim_lint", { clear = true })
```

### Comment style (from lsp.lua, editor.lua)

```lua
-- ── Section header ───────────────────────────────────────────────────────
-- One-line explanation of why, not what.
```

---

## IMPLEMENTATION PLAN

### Phase A: Create `lua/plugins/formatting.lua`

Single spec for `stevearc/conform.nvim`. Uses `opts = {}` pattern (lazy.nvim calls `setup`
automatically). format_on_save enabled for all configured filetypes; yaml and helm fall back to
their LSP formatters (yamlls and helm_ls respectively) via `lsp_format = "fallback"`.

### Phase B: Create `lua/plugins/linting.lua`

Single spec for `mfussenegger/nvim-lint`. Uses `config = function()` because nvim-lint requires
imperative `lint.linters_by_ft` assignment and an autocmd — there is no `setup()` call. Python
is intentionally excluded (ruff LSP covers it). Helm is excluded (helm_ls provides diagnostics).

---

## STEP-BY-STEP TASKS

### TASK 1: CREATE `lua/plugins/formatting.lua`

**IMPLEMENT:**

```lua
-- lua/plugins/formatting.lua — format-on-save runner
-- conform.nvim runs standalone formatters (goimports, stylua, shfmt, ruff_format).
-- yaml and helm have no standalone formatter — lsp_format = "fallback" delegates to yamlls / helm_ls.
-- All binaries already installed by mason.nvim (lsp.lua lines 26–35).

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },

    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "Format buffer",
      },
    },

    opts = {

      -- ── Per-filetype formatters ────────────────────────────────────────
      -- Only filetypes with a standalone conform formatter are listed.
      -- yaml and helm are absent: lsp_format = "fallback" in format_on_save
      -- delegates to yamlls / helm_ls for those buffers automatically.
      formatters_by_ft = {
        python = { "ruff_format" },   -- ruff replaces black + isort
        go     = { "goimports" },     -- goimports = gofmt + import management
        lua    = { "stylua" },
        sh     = { "shfmt" },
        bash   = { "shfmt" },
        zsh    = { "shfmt" },
      },

      -- ── Format on save ────────────────────────────────────────────────
      -- Runs synchronously before BufWritePre completes (blocking, but fast).
      -- lsp_format = "fallback": if no conform formatter is configured for the
      -- current filetype, ask the LSP server to format instead.
      -- timeout_ms: 500ms is generous; stylua/shfmt are typically < 50ms.
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },

    },
  },
}
```

**PATTERN:** `opts = {}` used in `editor.lua` (oil, which-key, autopairs) — lazy.nvim calls `setup(opts)`.
**PATTERN:** `keys = {}` with `function()` callback used throughout `snacks.lua`.
**GOTCHA:** `lsp_fallback = true` is the old API (pre-v7). Use `lsp_format = "fallback"` instead.
  If the installed version is older, both keys work; newer versions warn on `lsp_fallback`.
**GOTCHA:** `ruff_format` (not `ruff`) is the conform formatter name for code formatting.
  `ruff` alone is the linter; `ruff_format` is the formatter. Do not swap them.
**GOTCHA:** `goimports` handles both `gofmt`-style formatting AND import organisation.
  Do NOT also add `gofmt` — they conflict.
**VALIDATE:** `:ConformInfo` in a Go file → shows `goimports` as active formatter, status = "ready"
**VALIDATE:** Open a Lua file, add trailing spaces, save → spaces removed, file formatted

---

### TASK 2: CREATE `lua/plugins/linting.lua`

**IMPLEMENT:**

```lua
-- lua/plugins/linting.lua — async linting runner
-- nvim-lint runs linters outside the LSP protocol and surfaces results as vim.diagnostic entries.
-- Python excluded: ruff LSP (lsp.lua) already provides diagnostics.
-- Helm excluded: helm_ls provides template diagnostics.
-- All binaries already installed by mason.nvim (lsp.lua lines 31–35).

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },

    -- nvim-lint has no setup() that accepts linters_by_ft.
    -- linters_by_ft must be set on the module directly; autocmd wires the trigger.
    -- config = function() is required — opts = {} alone does nothing.
    config = function()
      local lint = require("lint")

      -- ── Per-filetype linters ──────────────────────────────────────────
      -- Key: vim filetype string (same as vim.bo.filetype).
      -- Value: list of linter names matching filenames in nvim-lint's linters/ dir.
      -- IMPORTANT: use underscore names, not hyphen (golangci_lint, not golangci-lint).
      lint.linters_by_ft = {
        go   = { "golangci_lint" },
        sh   = { "shellcheck" },
        bash = { "shellcheck" },
        zsh  = { "shellcheck" },
        yaml = { "yamllint" },
      }

      -- ── Lint trigger ─────────────────────────────────────────────────
      -- BufReadPost: lint when a file is opened (shows existing issues immediately).
      -- BufWritePost: lint after every save (picks up new issues instantly).
      -- try_lint() is non-blocking; it fires the linter and callbacks update diagnostics.
      local lint_group = vim.api.nvim_create_augroup("ssnvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group    = lint_group,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
```

**PATTERN:** `config = function()` used in `treesitter.lua` (lines 15–65), `lsp.lua` (lines 19–44).
**PATTERN:** Augroup name `ssnvim_lint` follows `ssnvim_{name}` convention from `autocmds.lua`.
**GOTCHA:** nvim-lint linter names use underscores: `golangci_lint` (NOT `golangci-lint`).
  The name must match the filename in `lua/lint/linters/` inside the nvim-lint plugin.
  If unsure, run `:lua print(vim.inspect(require("lint").linters))` to see all registered names.
**GOTCHA:** `try_lint()` without arguments lints using `linters_by_ft[vim.bo.filetype]`.
  Calling it for a filetype with no entry is a no-op — safe on all buffers.
**GOTCHA:** zsh: `shellcheck` only partially supports zsh syntax. Diagnostics may include
  false positives for zsh-specific constructs. Acceptable for MVP; can be removed if noisy.
**VALIDATE:** Open a Go file with an unused import → golangci_lint diagnostic appears in sign column
**VALIDATE:** Open a shell file with `[ $var ]` (unquoted) → shellcheck diagnostic appears
**VALIDATE:** `:lua print(vim.inspect(require("lint").linters_by_ft))` → shows all configured filetypes

---

## VALIDATION COMMANDS

### Level 1: Plugin load check

```
:Lazy
```
Expected: `conform.nvim` and `nvim-lint` both show status "loaded" (or "not loaded" if no BufWritePost has fired yet — that is correct lazy behaviour).

### Level 2: Formatter verification

```
# Open any Go file, then:
:ConformInfo
```
Expected: `goimports` listed as formatter for `go`, status = "ready" (not "not found").

### Level 3: Format-on-save

```bash
# Outside Neovim:
echo 'x = 1+1' > /tmp/test.py
nvim /tmp/test.py
# In Neovim: add trailing spaces to a line, then :w
# Expected: trailing spaces removed, ruff_format applied (spacing normalised)
```

### Level 4: Manual format keymap

```
# In any configured filetype buffer:
<leader>cf
```
Expected: which-key shows "Format buffer" under `<leader>c` group; buffer formats on press.

### Level 5: Linting verification

```
# Open a YAML file with an intentional yamllint error (e.g. trailing spaces):
nvim /tmp/test.yaml
# Expected: diagnostic sign appears in sign column; :lua vim.diagnostic.open_float() shows detail
```

### Level 6: Startup time

```bash
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
```
Expected: < 100ms. Both plugins are event-loaded and add < 2ms to startup.

---

## ACCEPTANCE CRITERIA

- [ ] `lua/plugins/formatting.lua` exists with `formatters_by_ft` for python/go/lua/sh/bash/zsh
- [ ] `format_on_save` enabled with `timeout_ms = 500` and `lsp_format = "fallback"`
- [ ] `<leader>cf` keymap works and appears in which-key under "code" group
- [ ] `lua/plugins/linting.lua` exists with `linters_by_ft` for go/sh/bash/zsh/yaml
- [ ] Lint autocmd uses augroup `ssnvim_lint` on `BufWritePost` + `BufReadPost`
- [ ] `:ConformInfo` shows formatters as "ready" (not "not found") in relevant filetypes
- [ ] golangci-lint diagnostics appear on a Go file with real issues
- [ ] shellcheck diagnostics appear on a shell file with real issues
- [ ] yamllint diagnostics appear on a YAML file with real issues
- [ ] Python linting still works via ruff LSP (no regression from excluding python in nvim-lint)
- [ ] Startup time remains < 100ms
- [ ] `lazy-lock.json` committed after plugins install

---

## COMPLETION CHECKLIST

- [ ] Task 1: `lua/plugins/formatting.lua` created
- [ ] Task 2: `lua/plugins/linting.lua` created
- [ ] `:Lazy` — no errors for either plugin
- [ ] `:ConformInfo` — all formatters show "ready"
- [ ] Format-on-save verified in a Go or Python file
- [ ] `<leader>cf` manual format works
- [ ] Lint diagnostics verified in Go + shell + YAML
- [ ] Startup time verified < 100ms
- [ ] `lazy-lock.json` committed

---

## NOTES

**Why no `formatting.lua` entry for yaml/helm?**
`yamlls` and `helm_ls` are already configured in `lsp.lua` and both support LSP document formatting.
`lsp_format = "fallback"` in `format_on_save` activates them automatically when no conform formatter
is registered for a filetype. Adding a standalone YAML formatter (e.g. `prettier`) would conflict.

**Why no python in `linters_by_ft`?**
`ruff` is configured as an LSP server in `lsp.lua` (via mason-lspconfig). It attaches as a real LSP
client and surfaces diagnostics through the standard `vim.diagnostic` pipeline. Adding `ruff` to
nvim-lint would create duplicate diagnostics. The ruff LSP path is strictly superior.

**Why `BufReadPost` instead of `BufReadPre` for linting?**
`BufReadPost` fires after the buffer is fully loaded and the filetype is set. `BufReadPre` fires
before `vim.bo.filetype` is populated — `try_lint()` would see an empty filetype and do nothing.

**golangci-lint performance note:**
golangci-lint is slower than shellcheck/yamllint (can take 5–15s on large Go projects). This is
expected — it runs many linters in parallel. Diagnostics update asynchronously so it does not
block typing. If it is too slow for a specific project, remove `golangci_lint` from `linters_by_ft`
and rely on gopls diagnostics instead.

**conform.nvim `lsp_format` values (for reference):**
- `"fallback"` — use LSP only when no conform formatter is configured for the filetype
- `"prefer"` — prefer LSP over conform formatters when both are available
- `"always"` — always run LSP formatter in addition to conform formatters
- `"never"` — never use LSP formatter (default without this key)
