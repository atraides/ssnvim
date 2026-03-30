# Feature: Phase 9 — GitHub Actions Support

The following plan should be complete, but validate documentation and codebase patterns before implementing.

Pay special attention to filetype string consistency (`yaml.github-actions`) across all four files — a single mismatch silently breaks the chain.

## Feature Description

Add full GitHub Actions workflow editing support to ssnvim: filetype detection for `.github/workflows/` files, the `gh-actions-language-server` LSP for expression-aware completions, `actionlint` async linting, and `Hdoc1509/gh-actions.nvim` for treesitter-based `${{ }}` expression syntax highlighting.

## User Story

As a developer who maintains CI/CD pipelines using GitHub Actions,
I want completions, diagnostics, and syntax highlighting for workflow files,
So that I catch expression errors and invalid workflow keys without leaving the editor.

## Problem Statement

`.github/workflows/*.yml` files are currently treated as plain `yaml` — `yamlls` attaches with schema validation (via SchemaStore) but has no awareness of GitHub Actions expressions, job dependencies, or action inputs/outputs. `${{ }}` expressions have no dedicated highlighting. There is no static linting for workflow syntax errors.

## Solution Statement

Introduce a custom `yaml.github-actions` filetype for workflow files. This naturally excludes `yamlls` (whose `filetypes` list does not include `yaml.github-actions`) and allows scoped tooling: `gh_actions_ls` for semantic completions, `actionlint` for static linting, and `Hdoc1509/gh-actions.nvim` treesitter injection for expression highlighting.

## Feature Metadata

**Feature Type**: New Capability
**Estimated Complexity**: Low
**Primary Systems Affected**: `autocmds.lua`, `lsp.lua`, `linting.lua`, `treesitter.lua`
**Dependencies**: `gh-actions-language-server` (Mason), `actionlint` (Mason), `Hdoc1509/gh-actions.nvim` (lazy.nvim)

---

## CONTEXT REFERENCES

### Relevant Codebase Files — MUST READ BEFORE IMPLEMENTING

- `lua/config/autocmds.lua` (lines 1–14) — `vim.filetype.add()` pattern for Helm; mirror this exact pattern for GitHub Actions
- `lua/plugins/lsp.lua` (lines 16–45) — Mason non-LSP tool installation pattern (`registry.refresh` + `pkg:install()`)
- `lua/plugins/lsp.lua` (lines 147–169) — `bashls` and `yamlls` `vim.lsp.config()` overrides; mirror the `filetypes` override for `gh_actions_ls`
- `lua/plugins/lsp.lua` (lines 204–218) — `mason-lspconfig.setup({ ensure_installed = {...} })`; add `"gh_actions_ls"` here
- `lua/plugins/linting.lua` (lines 22–28) — `lint.linters_by_ft` table; add `["github-actions"]` key
- `lua/plugins/treesitter.lua` (lines 3–68) — full spec; add `dependencies`, call `setup()` before treesitter config, add parser to `ensure_installed`

### New Files to Create

None — all changes are additive modifications to existing files.

### Relevant Documentation — READ BEFORE IMPLEMENTING

- [nvim-lspconfig gh_actions_ls config](https://github.com/neovim/nvim-lspconfig/blob/master/lsp/gh_actions_ls.lua)
  - Section: `filetypes`, `root_dir` logic, `init_options`
  - Why: Confirms default `filetypes = { 'yaml' }` which must be overridden to `yaml.github-actions`; `root_dir` scopes to `.github/workflows/` and does not need changes
- [Hdoc1509/gh-actions.nvim README](https://github.com/Hdoc1509/gh-actions.nvim)
  - Section: Installation, `require("gh-actions.tree-sitter").setup()` call order requirement
  - Why: Setup MUST be called before nvim-treesitter parser installation or the grammar will not register
- [mfussenegger/nvim-lint — compound filetypes](https://github.com/mfussenegger/nvim-lint#filetypes-with-dots)
  - Section: "Filetypes with dots"
  - Why: For `yaml.github-actions` filetype, use `["github-actions"]` as the `linters_by_ft` key (the suffix component); `yaml` key also runs for all yaml files

### Patterns to Follow

**Filetype detection (mirror `autocmds.lua` lines 8–14):**
```lua
-- Use vim.filetype.add(), NOT an autocmd. Runs before BufRead, so LSP and
-- treesitter see the correct ft on first attach.
vim.filetype.add({
  pattern = {
    [".*/.github/workflows/.*%.yml"]  = "yaml.github-actions",
    [".*/.github/workflows/.*%.yaml"] = "yaml.github-actions",
  },
})
```

**Mason non-LSP tool installation (mirror `lsp.lua` lines 26–44):**
```lua
local tools = {
  -- existing tools ...
  "actionlint",  -- github actions linting
}
-- (append to the existing tools table, do not create a new one)
```

**LSP filetypes override (mirror `lsp.lua` lines 147–149):**
```lua
vim.lsp.config("gh_actions_ls", {
  filetypes = { "yaml.github-actions" },
  -- Do NOT set init_options — the default config already has init_options = {}
  -- which is required. Omitting it here lets the default stay in place.
})
```

**mason-lspconfig ensure_installed (mirror `lsp.lua` lines 209–217):**
```lua
-- Add alongside existing servers — use lspconfig name (underscores), not Mason name (hyphens)
"gh_actions_ls",   -- github actions (mason pkg: gh-actions-language-server)
```

**nvim-lint compound filetype key (mirror `linting.lua` lines 22–28):**
```lua
lint.linters_by_ft = {
  -- existing entries ...
  ["github-actions"] = { "actionlint" },  -- fires only on yaml.github-actions ft
}
-- Note: "github-actions" matches the suffix component of "yaml.github-actions".
-- "yaml" key continues to fire yamllint on plain yaml files.
-- Both keys fire for yaml.github-actions buffers (yaml + github-actions).
-- This is intentional: yamllint validates YAML syntax, actionlint validates Actions semantics.
```

**treesitter dependency + pre-setup (mirror `treesitter.lua` lines 3–68):**
```lua
{
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "Hdoc1509/gh-actions.nvim",  -- must be a dependency so it loads before config runs
  },
  config = function()
    -- MUST be called before nvim-treesitter.configs.setup() so the grammar
    -- is registered in nvim-treesitter's parser list before install runs.
    require("gh-actions.tree-sitter").setup()

    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        -- existing parsers ...
        "gh_actions_expressions",  -- injected into yaml blocks for ${{ }} highlighting
      },
      -- rest of config unchanged
    })
  end,
}
```

---

## IMPLEMENTATION PLAN

### Phase 1: Filetype Foundation
Establish the `yaml.github-actions` filetype so all subsequent tooling has a stable anchor.

### Phase 2: LSP + Tools
Wire up `gh_actions_ls` through Mason + mason-lspconfig, and add `actionlint` to the non-LSP tool installer.

### Phase 3: Linting
Map `["github-actions"]` → `{ "actionlint" }` in nvim-lint so it fires only for workflow files.

### Phase 4: Treesitter Expression Highlighting
Add `Hdoc1509/gh-actions.nvim` as a treesitter dependency, call its setup, and install the `gh_actions_expressions` grammar.

---

## STEP-BY-STEP TASKS

IMPORTANT: Execute in order. Each task is atomic.

---

### Task 1 — UPDATE `lua/config/autocmds.lua`

- **ADD**: `vim.filetype.add()` block for `.github/workflows/*.yml` → `yaml.github-actions`, directly after the existing Helm block (line 14)
- **PATTERN**: Mirror the Helm block at `autocmds.lua:8–14`; use the same `vim.filetype.add()` function (not a BufRead autocmd)
- **GOTCHA**: Pattern uses Lua regex, not glob — `%.yml` escapes the dot; `.*` is Lua wildcard. Both `.yml` and `.yaml` extensions must be covered.
- **GOTCHA**: `yaml.github-actions` uses a hyphen — this is a valid Neovim filetype string. Neovim accepts dots and hyphens in filetype names.
- **VALIDATE**: `nvim --headless -c "lua vim.filetype.add({})" -c "qa" 2>&1 | head -5` (syntax check)
- **MANUAL VALIDATE**: Open a file in `.github/workflows/` and run `:set ft?` — should print `filetype=yaml.github-actions`

---

### Task 2 — UPDATE `lua/plugins/lsp.lua` — add `actionlint` to Mason tools

- **ADD**: `"actionlint"` to the `tools` table inside the mason.nvim `config` function (lines 26–35)
- **PATTERN**: Same pattern as `"shellcheck"`, `"yamllint"` — same table, same `registry.refresh` loop
- **GOTCHA**: This table is for non-LSP tools only. Do NOT add `actionlint` to `mason-lspconfig.ensure_installed` — it is not an LSP server.
- **VALIDATE**: After Neovim launch, `:Mason` → `actionlint` appears with a checkmark

---

### Task 3 — UPDATE `lua/plugins/lsp.lua` — add `gh_actions_ls` config override

- **ADD**: `vim.lsp.config("gh_actions_ls", { filetypes = { "yaml.github-actions" } })` block in section D (per-server config), after the `helm_ls` block (line 182)
- **PATTERN**: Mirror `bashls` override at `lsp.lua:147–149` — minimal override, only the fields that differ from defaults
- **GOTCHA**: Do NOT set `init_options` in the override — the nvim-lspconfig default already has `init_options = {}` which is required for server initialization (omitting it from your override is correct; `vim.lsp.config()` merges, not replaces, defaults)
- **GOTCHA**: Default `filetypes = { 'yaml' }`. Without the override, `gh_actions_ls` would attach to all `yaml` files (not just workflow files) — the override restricts it to `yaml.github-actions`
- **NOTE**: `root_dir` does not need overriding — the default already scopes to `.github/workflows/` directories via path check
- **VALIDATE**: Open a workflow file, run `:LspInfo` — `gh_actions_ls` should be listed as active

---

### Task 4 — UPDATE `lua/plugins/lsp.lua` — add `gh_actions_ls` to `ensure_installed`

- **ADD**: `"gh_actions_ls"` to the `mason-lspconfig.setup({ ensure_installed = {...} })` table (lines 209–217)
- **PATTERN**: Mirror the existing entries — use lspconfig name (underscores), with a comment showing the Mason package name (hyphens)
- **COMMENT**: `"gh_actions_ls",   -- github actions (mason pkg: gh-actions-language-server)`
- **GOTCHA**: Mason package name is `gh-actions-language-server` (hyphens); lspconfig name is `gh_actions_ls` (underscores). The `ensure_installed` list uses the lspconfig name.
- **VALIDATE**: After Neovim launch, `:Mason` → `gh-actions-language-server` appears installed

---

### Task 5 — UPDATE `lua/plugins/linting.lua` — add actionlint

- **ADD**: `["github-actions"] = { "actionlint" }` entry to `lint.linters_by_ft` table (lines 22–28)
- **PATTERN**: Mirror existing entries in the same table
- **GOTCHA**: Key must be `["github-actions"]` (bracket notation because hyphens are not valid unquoted Lua identifiers). Do NOT use `"yaml.github-actions"` as the key — use only the suffix `"github-actions"` which nvim-lint extracts from the compound filetype.
- **GOTCHA**: The `yaml` key (`yaml = { "yamllint" }`) will ALSO fire for `yaml.github-actions` buffers (nvim-lint runs linters for all matching components of a compound filetype). This is intentional — yamllint checks YAML syntax, actionlint checks Actions semantics. Both running is correct behavior.
- **VALIDATE**: Open a workflow file with a known error (e.g., invalid `on:` key), save, and check `:lua vim.diagnostic.get(0)` shows actionlint diagnostics

---

### Task 6 — UPDATE `lua/plugins/treesitter.lua` — add `gh-actions.nvim`

This task has three sub-changes to the single nvim-treesitter spec:

**6a**: Add `dependencies` table to the nvim-treesitter spec (currently no `dependencies` key exists):
```lua
dependencies = { "Hdoc1509/gh-actions.nvim" },
```

**6b**: At the TOP of `config = function()`, before the `require("nvim-treesitter.configs").setup({...})` call, add:
```lua
-- Must run before nvim-treesitter.configs.setup() so the gh_actions_expressions
-- grammar is registered in the parser list before auto-install runs.
require("gh-actions.tree-sitter").setup()
```

**6c**: Add `"gh_actions_expressions"` to the `ensure_installed` parser list inside `.setup({...})`:
```lua
ensure_installed = {
  -- existing parsers ...
  "gh_actions_expressions",  -- injected grammar for ${{ }} expression highlighting
},
```

- **GOTCHA**: `Hdoc1509/gh-actions.nvim` — note the capital `H`. This is a different repo from `topaxi/gh-actions.nvim` (which has been renamed to `topaxi/pipeline.nvim` and is a CI dashboard, not highlighting). Verify the exact GitHub handle.
- **GOTCHA**: `require("gh-actions.tree-sitter").setup()` MUST precede `require("nvim-treesitter.configs").setup()`. If order is reversed, the grammar won't be registered and `:TSInstall gh_actions_expressions` will fail.
- **GOTCHA**: `setup()` takes no arguments for default behaviour — call it bare with no opts table.
- **VALIDATE**: Open a workflow file → `:TSBufInfo` → `gh_actions_expressions` appears in injection list; `${{ secrets.FOO }}` renders with distinct highlighting

---

## TESTING STRATEGY

This project has no automated test suite — validation is manual via Neovim health checks and in-editor observation.

### Edge Cases

- File at `.github/workflows/test.yml` → ft should be `yaml.github-actions`, NOT `yaml`
- File at `.github/dependabot.yml` (NOT in `workflows/`) → ft should remain `yaml`
- File in `templates/*.yaml` → ft should remain `helm` (regression check)
- Plain `k8s-manifest.yaml` at project root → ft should remain `yaml`, yamllint fires, actionlint does NOT fire
- `${{ env.FOO }}` expression in a workflow file → highlighted distinctly from surrounding YAML keys
- Workflow file with invalid job key → actionlint diagnostic appears after save; gh_actions_ls also shows diagnostic

---

## VALIDATION COMMANDS

### Level 1: Plugin load check
```bash
nvim --headless -c "lua require('lazy').load({plugins='gh-actions.nvim'})" -c "qa" 2>&1
```
Expected: no errors

### Level 2: Parser installation
```bash
nvim --headless -c "TSInstall gh_actions_expressions" -c "qa" 2>&1
```
Expected: parser installs without error (or is already installed)

### Level 3: LSP server install
Inside Neovim after launch:
```
:Mason
```
Expected: `gh-actions-language-server` and `actionlint` both have ✓ (installed)

### Level 4: Filetype detection
```bash
nvim --headless -c "lua vim.cmd('e .github/workflows/test.yml')" \
  -c "lua print(vim.bo.filetype)" -c "qa" 2>&1
```
Expected output: `yaml.github-actions`

### Level 5: Manual in-editor validation checklist
1. Open any `.github/workflows/*.yml` file
2. `:set ft?` → `yaml.github-actions`
3. `:LspInfo` → `gh_actions_ls` active; `yamlls` NOT active
4. Type `on:` → completions for `push`, `pull_request`, `workflow_dispatch`, etc.
5. Type `${{ secrets.` → expression completions or at minimum no error
6. Introduce a known actionlint error (e.g., `runs-on: bad value`), save → diagnostic appears
7. `:TSBufInfo` → `gh_actions_expressions` injected
8. `${{ env.SOME_VAR }}` → expression tokens highlighted differently from YAML keys
9. Open `k8s/deployment.yaml` → ft `yaml`, `:LspInfo` shows `yamlls` active, `gh_actions_ls` NOT active (regression)
10. Open `charts/app/templates/deployment.yaml` → ft `helm` (regression)

---

## ACCEPTANCE CRITERIA

- [ ] `.github/workflows/*.yml` files get `ft=yaml.github-actions`
- [ ] `.github/workflows/*.yaml` files get `ft=yaml.github-actions`
- [ ] Non-workflow YAML files retain `ft=yaml` (regression)
- [ ] Helm files retain `ft=helm` (regression)
- [ ] `gh_actions_ls` attaches to workflow buffers
- [ ] `yamlls` does NOT attach to workflow buffers
- [ ] `gh-actions-language-server` is auto-installed by Mason on first launch
- [ ] `actionlint` is auto-installed by Mason on first launch
- [ ] `actionlint` fires on `BufWritePost` / `BufReadPost` for workflow files
- [ ] `actionlint` does NOT fire on plain `yaml` files (regression)
- [ ] `yamllint` still fires on plain `yaml` files (regression)
- [ ] `${{ }}` expressions are highlighted distinctly via treesitter injection
- [ ] `:TSInstall gh_actions_expressions` installs without error
- [ ] Startup time remains < 100ms (all new additions are lazy or event-driven)

---

## COMPLETION CHECKLIST

- [ ] Task 1: `autocmds.lua` — filetype detection added
- [ ] Task 2: `lsp.lua` — `actionlint` in Mason non-LSP tools
- [ ] Task 3: `lsp.lua` — `gh_actions_ls` filetypes override added
- [ ] Task 4: `lsp.lua` — `gh_actions_ls` in `ensure_installed`
- [ ] Task 5: `linting.lua` — `["github-actions"] = { "actionlint" }` added
- [ ] Task 6: `treesitter.lua` — dependency, pre-setup call, parser added
- [ ] All manual validation steps pass
- [ ] No regression on Helm, plain YAML, or other filetypes
- [ ] `lazy-lock.json` updated after `:Lazy sync` and committed

---

## NOTES

### Why `yaml.github-actions` and not `yaml`?

Keeping `yaml` filetype for workflow files would:
- Cause `actionlint` to fire on every YAML file in the project (no scoping mechanism in nvim-lint without a custom filetype)
- Cause `yamlls` to attach alongside `gh_actions_ls` (redundant diagnostics, possible conflicts)

The `yaml.github-actions` compound filetype is the standard nvim-lint recommended pattern for this exact situation.

### Why not `topaxi/gh-actions.nvim`?

`topaxi/gh-actions.nvim` has been renamed to `topaxi/pipeline.nvim` and is a CI/CD run dashboard (requires `gh` CLI + `make` build). It is NOT a treesitter highlighting plugin. The correct plugin for `${{ }}` expression highlighting is `Hdoc1509/gh-actions.nvim`.

### yamlls and SchemaStore

`yamlls` with SchemaStore includes a GitHub Workflow schema (`github-workflow.json`) that provides basic key validation. After this phase, `yamlls` will no longer attach to workflow files — that schema validation is replaced by the more capable `gh_actions_ls`. This is a net improvement.

### gh_actions_ls `init_options = {}` requirement

The `gh_actions_ls` server fails to initialize if `init_options` is absent. The default nvim-lspconfig config (`lsp/gh_actions_ls.lua`) already includes it. Since `vim.lsp.config()` merges with defaults (not replaces), the override in Task 3 only changes `filetypes` — `init_options` remains from the default. Safe as long as the override does not explicitly set `init_options = nil`.

### Confidence Score: 8/10

Deduction for:
- `Hdoc1509/gh-actions.nvim` is a less-established plugin; API may differ slightly from research — verify README before implementing Task 6
- The `require("gh-actions.tree-sitter").setup()` call order requirement is critical and easy to get wrong
