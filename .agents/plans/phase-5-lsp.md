# Feature: Phase 5 — LSP (Language Server Protocol)

The following plan should be complete, but validate codebase patterns and documentation before implementing.
Pay special attention to the Helm/YAML conflict — it is the single most critical correctness concern.

## Feature Description

Add full LSP support to ssnvim via `mason.nvim` (tool installer), `mason-lspconfig.nvim` (bridge),
`nvim-lspconfig` (LSP client), and `schemastore.nvim` (YAML schema catalog). This phase delivers code
intelligence — hover docs, go-to-definition, diagnostics, rename, code actions — for all languages in
the user's stack: Python, Go, Bash, YAML/Kubernetes, Helm, and Lua.

## User Story

As a developer working across Python, Go, Kubernetes YAML, and Helm charts,
I want language-aware completions, type checking, inline diagnostics, and go-to-definition,
so that I catch errors and navigate code without leaving Neovim.

## Problem Statement

Phases 1–4 deliver a beautiful, navigable editor with syntax highlighting. Missing: semantic intelligence.
No LSP means no type errors, no hover docs, no rename, and no schema validation for Kubernetes manifests.

## Solution Statement

Single new file `lua/plugins/lsp.lua` wires four plugins into a complete LSP stack.
Mason auto-installs all 13 tools on first launch. Server configs handle language-specific requirements
(Python venv detection, YAML schema injection, Helm/YAML conflict resolution).
Buffer-local keymaps are registered via `LspAttach` autocmd per the established project convention.

## Feature Metadata

**Feature Type**: New Capability
**Estimated Complexity**: Medium-High
**Primary Systems Affected**: `lua/plugins/lsp.lua` (new file only)
**Dependencies**: mason.nvim, mason-lspconfig.nvim, nvim-lspconfig, schemastore.nvim

---

## CONTEXT REFERENCES

### Relevant Codebase Files — MUST READ BEFORE IMPLEMENTING

- `lua/config/autocmds.lua` (lines 1–14) — `vim.filetype.add()` already sets `ft=helm` for
  `templates/*.yaml`. LSP must respect this. Do NOT add helm detection in lsp.lua.
- `lua/config/keymaps.lua` (lines 45–49) — Diagnostic keymaps `[d`, `]d`, `<leader>e` already exist.
  Do NOT re-add them in LspAttach. LSP keymaps start from `gd`, `K`, `<leader>l*`.
- `lua/plugins/editor.lua` (lines 81–97) — which-key already registers `{ "<leader>l", group = "lsp" }`
  and `{ "<leader>c", group = "code" }`. LSP keymaps under `<leader>l*` will auto-populate these groups.
- `lua/plugins/snacks.lua` (lines 22–26) — `<leader>fs` (lsp_symbols) and `<leader>fd` (diagnostics)
  are already bound. They were no-ops before Phase 5 — they become functional now automatically.
- `lua/plugins/treesitter.lua` (lines 15–66) — treesitter uses `config = function()` pattern because
  `nvim-treesitter.configs.setup()` must be called explicitly. lspconfig will need the same approach.
- `init.lua` (lines 32–37) — `spec = { { import = "plugins" } }` auto-discovers all files in
  `lua/plugins/`. No changes to init.lua needed; creating lsp.lua is sufficient.

### New File to Create

- `lua/plugins/lsp.lua` — Full LSP stack: mason + mason-lspconfig + lspconfig + schemastore

### Relevant Documentation — READ BEFORE IMPLEMENTING

- https://github.com/williamboman/mason.nvim#configuration
  - Section: `ensure_installed` list format and Mason package names vs lspconfig names
  - Why: Mason package names differ from lspconfig server names (e.g. `lua-language-server` vs `lua_ls`)
- https://github.com/williamboman/mason-lspconfig.nvim#setup
  - Section: `setup_handlers` API — default handler + per-server overrides
  - Why: This is the pattern we'll use to DRY up server setup
- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
  - Sections: `pyright`, `ruff`, `gopls`, `bashls`, `yamlls`, `helm_ls`, `lua_ls`
  - Why: Each entry lists the exact `settings` key structure and `filetypes` defaults
- https://github.com/b0o/SchemaStore.nvim#usage
  - Section: YAML schemas usage
  - Why: Shows exact call: `require("schemastore").yaml.schemas()`
- https://luals.github.io/wiki/settings/
  - Section: `Lua.workspace.library` and `Lua.diagnostics.globals`
  - Why: lua_ls needs Neovim runtime in workspace.library to resolve `vim.*` globals

### Patterns to Follow

**Plugin spec with dependencies (from treesitter.lua):**
```lua
-- Use config = function() when setup() must be called explicitly
{
  "neovim/nvim-lspconfig",
  dependencies = { ... },
  event = { "BufReadPre", "BufNewFile" },
  config = function() ... end,
}
```

**Keybinding convention (from CLAUDE.md + keymaps.lua):**
```lua
-- Always include desc; LSP keymaps must be buffer-local via LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to definition" })
  end,
})
```

**Augroup pattern (from autocmds.lua):**
```lua
local group = vim.api.nvim_create_augroup("ssnvim_lsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", { group = group, ... })
```

**Keybinding groups already registered in which-key (editor.lua:89–96):**
- `<leader>l` → "lsp" group (use `<leader>l*` for LSP operations)
- `<leader>c` → "code" group (reserved for Phase 7 format/lint)

---

## IMPLEMENTATION PLAN

### Phase A: Mason — Tool Installation

Configure mason.nvim to auto-install all 13 tools on first launch.
Separate LSP servers from formatters/linters in the `ensure_installed` list via comments.

### Phase B: mason-lspconfig Bridge

Use `setup_handlers` to configure a default handler (bare `lspconfig[name].setup()`) plus
explicit overrides for servers needing custom config: pyright, yamlls, helm_ls, lua_ls, bashls.

### Phase C: Server-Specific Configs

The five servers that need explicit config (in order of importance):
1. **yamlls** — SchemaStore injection + `filetypes` that excludes `helm` (CRITICAL)
2. **helm_ls** — explicit `filetypes = { "helm" }` (prevents it from grabbing plain YAML)
3. **lua_ls** — Neovim runtime in workspace.library so `vim.*` resolves without errors
4. **pyright** — `before_init` venv detection for `.venv/`, `venv/`, with pyenv fallback
5. **bashls** — explicit `filetypes` to include `zsh` (not in default list)

### Phase D: LspAttach Keymaps + Diagnostic Config

Global diagnostic display config (`vim.diagnostic.config`) + buffer-local LspAttach keymaps.
Capabilities use `vim.lsp.protocol.make_client_capabilities()` now; Phase 6 will override with
`require("blink.cmp").get_lsp_capabilities()` — leave a clear comment marking the update point.

---

## STEP-BY-STEP TASKS

### CREATE `lua/plugins/lsp.lua`

The file returns a table of four plugin specs. Implement them in this exact order within the file.

---

#### SPEC 1: mason.nvim

- **IMPLEMENT**: Standalone spec, `lazy = false` so Mason UI is always available
- **IMPLEMENT**: `opts.ensure_installed` lists all 13 tools using Mason package names
  - LSP servers: `"pyright"`, `"ruff"`, `"gopls"`, `"bash-language-server"`,
    `"yaml-language-server"`, `"helm-ls"`, `"lua-language-server"`
  - Formatters (pre-install for Phase 7): `"goimports"`, `"shfmt"`, `"stylua"`
  - Linters (pre-install for Phase 7): `"golangci-lint"`, `"shellcheck"`, `"yamllint"`
- **GOTCHA**: Mason package names use hyphens; lspconfig server names use underscores.
  `"lua-language-server"` in Mason → `"lua_ls"` in lspconfig. `"bash-language-server"` → `"bashls"`.
- **VALIDATE**: `:Mason` opens UI showing all tools queued/installed

---

#### SPEC 2: mason-lspconfig.nvim

- **IMPLEMENT**: Listed as a `dependencies` entry under nvim-lspconfig spec (not a standalone spec).
  mason-lspconfig must be loaded after mason.nvim and before lspconfig.
- **IMPLEMENT**: `require("mason-lspconfig").setup({ ensure_installed = {} })` — empty list here;
  Mason handles installation via mason.nvim's `ensure_installed`. mason-lspconfig's role is the bridge.
- **GOTCHA**: Do NOT duplicate the ensure_installed list in mason-lspconfig. One source of truth in mason.

---

#### SPEC 3: schemastore.nvim

- **IMPLEMENT**: Listed as a `dependencies` entry under nvim-lspconfig spec (no setup needed).
  Used only inline inside the yamlls server config.
- **VALIDATE**: `lua print(vim.inspect(require("schemastore").yaml.schemas()))` returns a table

---

#### SPEC 4: nvim-lspconfig (main config spec)

Structure:
```lua
{
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "b0o/schemastore.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- A. Diagnostic display config
    -- B. Capabilities (with Phase 6 update comment)
    -- C. LspAttach keymaps
    -- D. mason-lspconfig setup() call
    -- E. setup_handlers with per-server overrides
  end,
}
```

**A. Diagnostic display config** — call before any server setup:
```lua
vim.diagnostic.config({
  virtual_text  = { spacing = 4, prefix = "●" },
  signs         = true,
  underline     = true,
  update_in_insert = false,  -- don't show diagnostics while typing
  severity_sort = true,
  float         = { border = "rounded", source = "always" },
})
```

**B. Capabilities** — standard for Phase 5; Phase 6 updates this one line:
```lua
-- Phase 6: replace this line with:
--   local capabilities = require("blink.cmp").get_lsp_capabilities()
local capabilities = vim.lsp.protocol.make_client_capabilities()
```

**C. LspAttach keymaps** — augroup + autocmd pattern from autocmds.lua:
```lua
local lsp_group = vim.api.nvim_create_augroup("ssnvim_lsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(event)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc })
    end
    -- Navigation (no prefix — standard Neovim LSP conventions)
    map("gd",  vim.lsp.buf.definition,      "Go to definition")
    map("gD",  vim.lsp.buf.declaration,     "Go to declaration")
    map("gI",  vim.lsp.buf.implementation,  "Go to implementation")
    map("K",   vim.lsp.buf.hover,           "Hover documentation")
    map("gr",  vim.lsp.buf.references,      "Find references")
    -- <leader>l group (already registered in which-key via editor.lua)
    map("<leader>lr", vim.lsp.buf.rename,       "Rename symbol")
    map("<leader>la", vim.lsp.buf.code_action,  "Code action")
    map("<leader>lf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer (LSP)")
    -- NOTE: [d, ]d, <leader>e already defined in keymaps.lua — do NOT redefine here
  end,
})
```

**D. mason-lspconfig.setup()** — call before setup_handlers:
```lua
require("mason-lspconfig").setup()
```

**E. setup_handlers** — default + five server overrides:

Default handler (all servers not explicitly overridden):
```lua
function(server_name)
  require("lspconfig")[server_name].setup({ capabilities = capabilities })
end,
```

**pyright override:**
```lua
["pyright"] = function()
  -- Detect virtual environment at project open time.
  -- Checks common venv locations: .venv (uv/poetry default), venv (classic).
  -- Falls back to pyenv shim or system Python if neither is found.
  local function get_python_path()
    local cwd = vim.fn.getcwd()
    for _, candidate in ipairs({ "/.venv/bin/python", "/venv/bin/python" }) do
      local path = cwd .. candidate
      if vim.fn.executable(path) == 1 then return path end
    end
    return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3")
      or vim.fn.exepath("python")
      or "python3"
  end

  require("lspconfig").pyright.setup({
    capabilities = capabilities,
    before_init  = function(_, config)
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = get_python_path()
    end,
    settings = {
      python = {
        analysis = {
          typeCheckingMode   = "standard",   -- not "strict" — practical balance
          autoSearchPaths    = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  })
end,
```

**ruff override:**
```lua
["ruff"] = function()
  -- Ruff provides linting diagnostics and code actions (fix issues).
  -- Formatting is handled by conform.nvim in Phase 7 — do not enable
  -- documentFormattingProvider here to avoid conflict.
  require("lspconfig").ruff.setup({ capabilities = capabilities })
end,
```

**bashls override:**
```lua
["bashls"] = function()
  -- Default filetypes: sh, bash. Add zsh explicitly.
  require("lspconfig").bashls.setup({
    capabilities = capabilities,
    filetypes    = { "bash", "sh", "zsh" },
  })
end,
```

**yamlls override (CRITICAL — must exclude helm):**
```lua
["yamlls"] = function()
  require("lspconfig").yamlls.setup({
    capabilities = capabilities,
    -- CRITICAL: helm filetype must NOT be in this list.
    -- autocmds.lua sets ft=helm for templates/*.yaml before LSP attach.
    -- If "helm" were here, yamlls would attach to Helm buffers and conflict with helm-ls.
    filetypes = { "yaml", "yaml.docker-compose" },
    settings = {
      yaml = {
        -- Disable built-in schema store; use schemastore.nvim catalog instead.
        -- schemastore.nvim provides K8s, ArgoCD, Helm values, GitHub Actions schemas.
        schemaStore = { enable = false, url = "" },
        schemas     = require("schemastore").yaml.schemas(),
        validate    = true,
        completion  = true,
        hover       = true,
      },
    },
  })
end,
```

**helm_ls override:**
```lua
["helm_ls"] = function()
  -- helm-ls handles Helm template intelligence (Go template + YAML).
  -- Explicit filetypes guard: only attach to ft=helm buffers.
  require("lspconfig").helm_ls.setup({
    capabilities = capabilities,
    filetypes    = { "helm" },
    settings = {
      ["helm-ls"] = {
        -- helm-ls has built-in yamlls integration for values files.
        -- Point it at the Mason-installed yaml-language-server.
        yamlls = { path = "yaml-language-server" },
      },
    },
  })
end,
```

**lua_ls override:**
```lua
["lua_ls"] = function()
  require("lspconfig").lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },  -- Neovim uses LuaJIT
        workspace = {
          checkThirdParty = false,          -- suppress "Do you want to configure..." prompt
          -- Add Neovim runtime files so lua_ls resolves vim.* without errors
          library = vim.api.nvim_get_runtime_file("", true),
        },
        diagnostics = {
          globals = { "vim" },  -- suppress "undefined global 'vim'" warnings
        },
        telemetry = { enable = false },
      },
    },
  })
end,
```

- **VALIDATE**: `:LspInfo` in a Python file shows pyright attached; in a Helm template shows helm_ls; in a YAML file shows yamlls; yamlls NOT shown in Helm files
- **VALIDATE**: `K` in a Lua file inside the config shows hover docs from lua_ls
- **VALIDATE**: `gd` on a Python symbol navigates to definition
- **VALIDATE**: `:checkhealth lspconfig` shows no errors

---

## VALIDATION COMMANDS

### Level 1: Startup Check
```
nvim --headless -c "lua require('lspconfig')" -c "qa" && echo "lspconfig loads OK"
```

### Level 2: Mason Installation
```
# Inside Neovim:
:Mason
# All 13 tools should show green checkmarks after first-launch install
```

### Level 3: Server Attachment Verification
```
# Open a Python file:
nvim /tmp/test.py
:LspInfo    → pyright and ruff listed as "1 client(s) attached"

# Open a YAML file (non-helm):
nvim /tmp/test.yaml
:LspInfo    → yamlls listed; helm_ls NOT listed

# Open a Helm template (requires a chart directory structure):
mkdir -p /tmp/testchart/templates && nvim /tmp/testchart/templates/deployment.yaml
:LspInfo    → helm_ls listed; yamlls NOT listed

# Open a Lua file:
nvim ~/.config/nvim/lua/config/options.lua
:LspInfo    → lua_ls listed
:lua vim.lsp.buf.hover()   → hover shows Lua docs (cursor on a vim.opt.* call)
```

### Level 4: Keymap Smoke Test
```
# In any LSP-attached buffer:
# Normal mode: press K → hover popup appears
# Normal mode: press gd → jumps to definition (or shows LSP error if no definition)
# Normal mode: <leader>la → code action menu appears (or "No code actions available")
# Normal mode: <leader>lr → rename prompt appears
```

### Level 5: Helm/YAML Conflict Check (Critical)
```
# This is the most important test. Must not fail.

# 1. Confirm ft=helm is set:
nvim /tmp/testchart/templates/deployment.yaml
:echo &filetype   → should print "helm"

# 2. Confirm yamlls is NOT attached:
:LspInfo          → should show helm_ls only, NOT yamlls

# 3. Open a plain YAML file:
nvim /tmp/k8s-deploy.yaml
:echo &filetype   → should print "yaml"
:LspInfo          → should show yamlls only, NOT helm_ls
```

---

## ACCEPTANCE CRITERIA

- [ ] `lua/plugins/lsp.lua` created with all four plugin specs
- [ ] `:Mason` shows all 13 tools installed (green) after first launch
- [ ] pyright attaches to `.py` files; ruff co-attaches for diagnostics
- [ ] `yamlls` attaches to `.yaml` files that are NOT in a Helm chart templates dir
- [ ] `helm_ls` attaches to `ft=helm` files; `yamlls` does NOT
- [ ] `lua_ls` attaches to `.lua` files; `vim.*` globals show no unknown-global warnings
- [ ] `K` shows hover docs in all LSP-attached buffers
- [ ] `gd` navigates to definition in Python, Go, and Lua files
- [ ] `<leader>lr` opens rename prompt
- [ ] `<leader>la` opens code action menu
- [ ] `<leader>lf` formats the buffer via LSP
- [ ] `[d` / `]d` / `<leader>e` still work (defined in keymaps.lua, not duplicated)
- [ ] `<leader>fs` (snacks lsp_symbols) now shows real symbols
- [ ] `<leader>fd` (snacks diagnostics) now shows real diagnostics
- [ ] No errors in `:checkhealth lspconfig`
- [ ] No errors in `:checkhealth mason`
- [ ] Startup time remains < 100ms (LSP loads lazily on BufReadPre)

---

## COMPLETION CHECKLIST

- [ ] All tasks completed top-to-bottom
- [ ] Level 1–5 validation commands executed
- [ ] Helm/YAML conflict test passed (Level 5 — critical)
- [ ] `:checkhealth` clean
- [ ] `lazy-lock.json` updated and committed

---

## NOTES

### Phase 6 Handoff Point

`lua/plugins/lsp.lua` has one marked update point for Phase 6:
```lua
-- Phase 6: replace this line with:
--   local capabilities = require("blink.cmp").get_lsp_capabilities()
local capabilities = vim.lsp.protocol.make_client_capabilities()
```
Phase 6 must update this single line in lsp.lua. No other changes to lsp.lua are expected.

### Python Venv Detection Tradeoff

The `before_init` function detects venv at server start time (when you open a buffer).
This means: if you open Neovim from outside the project directory, then `cd` to it, pyright may
have the wrong Python. Workaround: open Neovim from within the project directory, or use
`:PyrightSetPythonPath <path>` to override manually. Documented as a known limitation.

### ruff + pyright Coexistence

Both attach to `.py` files. pyright provides type checking; ruff provides lint diagnostics
and code-fix actions. They do not conflict because they cover different domains. When both
show a "diagnostic" for the same issue (rare), severity_sort in diagnostic config ensures
errors appear before warnings regardless of source.

### helm-ls Internal yamlls

`helm_ls` internally spawns its own `yaml-language-server` process for Helm values files
(`values.yaml`, `values-*.yaml`). This is separate from our global `yamlls` instance.
The `yamlls.path` setting in helm_ls config points it to the Mason-installed binary so it
uses the same version.

### Startup Time Impact

`event = { "BufReadPre", "BufNewFile" }` on the lspconfig spec means none of these four
plugins load until a file buffer is opened. The bare `nvim` dashboard invocation remains
unaffected. Startup time impact: ~0ms for cold start, ~15–30ms on first buffer open.

### Confidence Score: 9/10

High confidence. The codebase patterns are well-established, the Helm/YAML conflict is
handled in autocmds.lua before Phase 5 runs, and mason-lspconfig's setup_handlers pattern
is stable. The one risk: Mason package registry names can occasionally drift from lspconfig
names — verify against mason-registry.dev if a server fails to install.
