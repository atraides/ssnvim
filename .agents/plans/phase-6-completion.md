# Feature: Phase 6 — Completion (blink.cmp + Copilot)

The following plan should be complete, but validate codebase patterns and documentation before implementing.
Pay special attention to load-order: blink.cmp must be available before `BufReadPre` fires so lsp.lua
can call `require("blink.cmp").get_lsp_capabilities()`. Set `lazy = false` on blink.cmp.

## Feature Description

Add fast, AI-assisted completion to ssnvim via `blink.cmp` (completion engine), `copilot.lua`
(Copilot backend), and `fang2hou/blink-copilot` (bridge). This phase wires GitHub Copilot suggestions
into the same completion menu as LSP completions, with Copilot appearing as a lower-priority source
below LSP. It also upgrades LSP capabilities (snippet support, `labelDetails`, etc.) by replacing
the basic `make_client_capabilities()` call in lsp.lua with `blink.cmp.get_lsp_capabilities()`.

## User Story

As a developer using Python, Go, and Kubernetes YAML daily,
I want LSP completions and GitHub Copilot suggestions in a single fast completion menu,
so that I accept the right completion (LSP type-accurate or Copilot AI-generated) without switching modes.

## Problem Statement

Phase 5 delivers LSP intelligence but no completion UI. The `vim.lsp.protocol.make_client_capabilities()`
call in lsp.lua also sends a minimal capability set — it does not advertise snippet support or
`labelDetails`, which limits what LSP servers return. There is also no mechanism for Copilot completions.

## Solution Statement

Single new file `lua/plugins/completion.lua` containing three plugin specs (copilot.lua, blink-copilot,
blink.cmp). `blink.cmp` is loaded eagerly (`lazy = false`) so it is available when lspconfig's config
function runs on `BufReadPre`. One targeted edit to `lua/plugins/lsp.lua` swaps the capabilities line
(a comment in lsp.lua already marks the exact location for this change).

## Feature Metadata

**Feature Type**: New Capability
**Estimated Complexity**: Low-Medium
**Primary Systems Affected**: `lua/plugins/completion.lua` (new), `lua/plugins/lsp.lua` (1-line edit)
**Dependencies**: `saghen/blink.cmp`, `zbirenbaum/copilot.lua`, `fang2hou/blink-copilot`

---

## CONTEXT REFERENCES

### Relevant Codebase Files — MUST READ BEFORE IMPLEMENTING

- `lua/plugins/lsp.lua` (lines 79–82) — The `Phase 6` comment marks exactly where to swap
  `vim.lsp.protocol.make_client_capabilities()` → `require("blink.cmp").get_lsp_capabilities()`.
  Do NOT change anything else in lsp.lua.
- `lua/plugins/editor.lua` (lines 82–97) — which-key already registers `{ "<leader>c", group = "code" }`.
  No completion keymaps go in this group (blink uses its own keymap table inside opts).
- `lua/config/keymaps.lua` — Confirms Tab/S-Tab/CR/C-space are not globally bound to anything.
  Safe to use in blink.cmp keymap config.
- `lua/plugins/snacks.lua` (line 3) — Notes the `Snacks` global pattern. blink.cmp does NOT use globals;
  all config is inside the opts table.
- `lua/plugins/treesitter.lua` (lines 3–8) — Uses `config = function()` because `opts = {}` alone doesn't
  call setup. blink.cmp uses `opts = {}` directly (lazy.nvim calls setup automatically).
- `init.lua` (line 34) — `defaults = { lazy = true }` — ALL plugins are lazy unless explicitly overridden.
  blink.cmp MUST set `lazy = false` (see Critical Gotcha below).

### New File to Create

- `lua/plugins/completion.lua` — Three plugin specs: copilot.lua, blink-copilot (dep only), blink.cmp

### Files to Edit

- `lua/plugins/lsp.lua` (lines 79–82) — Swap capabilities line as marked by the Phase 6 comment

### Relevant Documentation — READ BEFORE IMPLEMENTING

- [blink.cmp Installation](https://cmp.saghen.dev/installation.html)
  - Section: lazy.nvim spec, `version = '1.*'` for pre-built Rust binary, `get_lsp_capabilities`
- [blink.cmp Keymap Config](https://cmp.saghen.dev/configuration/keymap.html)
  - Section: preset names (`default`, `super-tab`, `enter`), custom key syntax `['<Key>'] = { 'action' }`
- [blink.cmp Sources Config](https://cmp.saghen.dev/configuration/sources.html)
  - Section: `sources.default` list, `sources.providers` table, `score_offset`, `async`
- [blink-copilot README](https://github.com/fang2hou/blink-copilot)
  - Section: `module = "blink-copilot"`, provider opts (`max_completions`, `kind_icon`, `debounce`)
- [copilot.lua README](https://github.com/zbirenbaum/copilot.lua)
  - Section: disable `suggestion` and `panel`, `event = "InsertEnter"` lazy-load pattern

---

## PATTERNS TO FOLLOW

### Lazy-load event pattern (from lsp.lua, treesitter.lua, editor.lua)
```lua
event = { "BufReadPre", "BufNewFile" }   -- lsp.lua
event = "InsertEnter"                     -- autopairs in editor.lua (insert-mode only plugins)
lazy  = false                             -- snacks.lua, rose-pine (must be available at startup)
```

### opts = {} pattern (blink.cmp supports this — no explicit config = function() needed)
```lua
-- CORRECT for blink.cmp (lazy.nvim calls require("blink.cmp").setup(opts) automatically)
opts = { keymap = { preset = "default" }, ... }

-- NOT needed (treesitter requires explicit .setup() call, blink does not)
config = function() require("blink.cmp").setup({}) end
```

### opts_extend for sources merging (blink.cmp specific)
```lua
opts_extend = { "sources.default" }   -- lets LazyVim extras append sources without overwriting
```
Include this even though LazyVim is not used — it is the blink.cmp convention for future-proofing.

### Copilot disable-suggestion pattern (from copilot.lua docs)
```lua
-- CORRECT: disable both inline suggestion UI and panel when blink handles display
opts = {
  suggestion = { enabled = false },
  panel      = { enabled = false },
}
```

### Provider opts nesting in blink.cmp (from blink-copilot docs)
```lua
providers = {
  copilot = {
    name         = "copilot",    -- display name
    module       = "blink-copilot",
    score_offset = 100,          -- boosts Copilot above buffer/path but below lsp (lsp ~= 1000)
    async        = true,
    opts         = {             -- blink-copilot-specific opts nested here
      max_completions = 3,
      kind_icon       = " ",
      kind_name       = "Copilot",
      debounce        = 200,
    },
  },
}
```

---

## CRITICAL GOTCHA: Load Order

`init.lua` sets `defaults = { lazy = true }` — every plugin is lazy unless overridden.

`lua/plugins/lsp.lua` config function calls `require("blink.cmp").get_lsp_capabilities()`.
That config function runs when `BufReadPre` fires (i.e., when the user opens any file).

If blink.cmp has `event = "InsertEnter"`, it has NOT loaded yet when `BufReadPre` fires.
`require("blink.cmp")` would still work (lazy.nvim loads on demand when required), but this
creates a fragile implicit dependency.

**Solution:** Set `lazy = false` on blink.cmp. It is lightweight at startup (no heavy Lua modules
are executed until completion is triggered). This matches the pattern used by snacks.nvim and
rose-pine — plugins that must be available from the first event.

**Do NOT** add blink.cmp as a `dependencies = {}` entry in lsp.lua. That would create a
cross-file plugin dependency that is hard to trace and violates the one-file-per-concern pattern.

---

## IMPLEMENTATION PLAN

### Phase A: Create `lua/plugins/completion.lua`

Three specs in dependency order: copilot.lua → (blink-copilot is just a dependency) → blink.cmp.

**Spec order within the file:**
1. copilot.lua — the Copilot LSP backend
2. blink.cmp — the completion engine (with `fang2hou/blink-copilot` as a dependency)

blink-copilot does NOT need its own top-level spec. It is declared as a dependency inside
blink.cmp's spec so lazy.nvim installs it. It has no `setup()` call of its own.

### Phase B: Edit `lua/plugins/lsp.lua`

Replace exactly lines 79–82 (the Phase 6 comment block + old capabilities line) with the
single `get_lsp_capabilities()` call. No other changes.

---

## STEP-BY-STEP TASKS

### TASK 1: CREATE `lua/plugins/completion.lua`

**IMPLEMENT:**

```lua
-- lua/plugins/completion.lua — completion engine + GitHub Copilot
-- blink.cmp replaces nvim-cmp. Uses a pre-built Rust fuzzy-matching binary (version = "1.*").
-- copilot.lua provides the Copilot LSP backend; blink-copilot bridges it into blink.cmp.

return {

  -- ── SPEC 1: copilot.lua — GitHub Copilot backend ─────────────────────────
  -- Connects to the Copilot LSP server. Must load before Insert mode so the
  -- LSP client is authenticated and attached before the first keystroke.
  -- suggestion and panel are disabled: blink.cmp handles all completion display.
  {
    "zbirenbaum/copilot.lua",
    cmd   = "Copilot",       -- allow :Copilot auth / :Copilot status from normal mode
    event = "InsertEnter",   -- attach LSP client on first insert (not needed at startup)
    opts  = {
      suggestion = { enabled = false },  -- disable inline ghost text — blink handles this
      panel      = { enabled = false },  -- disable copilot panel
    },
  },

  -- ── SPEC 2: blink.cmp — completion engine ────────────────────────────────
  -- version = "1.*": downloads the pre-built Rust binary from a release tag.
  -- Do NOT use version = "main" or omit version — that requires a local Rust toolchain.
  --
  -- lazy = false: blink must be loaded at startup because lua/plugins/lsp.lua calls
  -- require("blink.cmp").get_lsp_capabilities() when BufReadPre fires (before InsertEnter).
  --
  -- fang2hou/blink-copilot is declared as a dependency (no top-level spec needed).
  -- It has no setup() of its own; it registers itself as a blink source module.
  {
    "saghen/blink.cmp",
    lazy         = false,
    version      = "1.*",
    dependencies = { "fang2hou/blink-copilot" },
    opts_extend  = { "sources.default" },

    opts = {

      -- ── Keymaps ───────────────────────────────────────────────────────────
      -- preset = "default" provides: C-n/C-p navigate, C-e dismiss, C-y accept.
      -- Additional overrides add Tab/S-Tab (item navigation + snippet jump) and
      -- CR (accept) and C-space (force trigger).
      keymap = {
        preset      = "default",
        ["<Tab>"]   = { "select_next",     "snippet_forward",  "fallback" },
        ["<S-Tab>"] = { "select_prev",     "snippet_backward", "fallback" },
        ["<CR>"]    = { "accept",          "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },

      -- ── Completion behaviour ──────────────────────────────────────────────
      completion = {
        -- Ghost text: inline preview of the selected item (dim, non-intrusive).
        -- Copilot suggestions appear as blink source items, not as separate ghost text.
        ghost_text = { enabled = true },
        -- Documentation popup: show on item select (not on hover delay).
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },

      -- ── Sources ───────────────────────────────────────────────────────────
      -- Priority order (left = highest): lsp > path > snippets > buffer > copilot.
      -- score_offset = 100 on copilot boosts it above buffer/path but lsp scores
      -- are naturally higher (~1000+) so lsp items still appear first.
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name         = "copilot",
            module       = "blink-copilot",
            score_offset = 100,
            async        = true,
            opts         = {
              max_completions = 3,      -- show up to 3 Copilot suggestions at a time
              kind_icon       = " ",  -- icon shown in completion menu
              kind_name       = "Copilot",
              debounce        = 200,    -- ms before firing a Copilot request
            },
          },
        },
      },

    },
  },

}
```

**PATTERN:** `lazy = false` used in `snacks.lua` (line 10), `ui.lua` (lines 29, 44, 60)
**GOTCHA:** `version = "1.*"` is mandatory. Without it (or with `version = "main"`), lazy.nvim
tries to build the Rust binary locally and fails unless `cargo` is installed.
**GOTCHA:** blink-copilot `opts` are nested under `providers.copilot.opts`, NOT at the provider
top level. `score_offset` and `async` are blink.cmp provider fields; everything else is blink-copilot config.
**VALIDATE:** `:Lazy` → blink.cmp shows no errors, status = "loaded"

---

### TASK 2: EDIT `lua/plugins/lsp.lua` (lines 79–82)

**IMPLEMENT:** Replace the Phase 6 comment block with the direct call.

**OLD (lines 79–82):**
```lua
      -- ── B. Capabilities — applied globally to all servers ───────────────
      -- vim.lsp.config('*', ...) is the v2 pattern for shared config.
      -- Phase 6: replace the capabilities line with:
      --   local capabilities = require("blink.cmp").get_lsp_capabilities()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })
```

**NEW:**
```lua
      -- ── B. Capabilities — applied globally to all servers ───────────────
      -- blink.cmp enhances the base capabilities with snippet support, labelDetails,
      -- and other completion features that LSP servers use to send richer responses.
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })
```

**PATTERN:** Mirrors the comment style used throughout lsp.lua (single `──` header, one-line explanation)
**GOTCHA:** `require("blink.cmp")` works here because blink.cmp has `lazy = false` (loaded at startup).
Do NOT add blink.cmp to lsp.lua's `dependencies` table — that cross-spec dependency is implicit via lazy=false.
**VALIDATE:** Open a Python file → `:LspInfo` shows pyright attached → completions include snippets

---

## VALIDATION COMMANDS

### Level 1: Plugin load check
```
:Lazy
```
Expected: blink.cmp, copilot.lua, blink-copilot all show status "loaded" or "not loaded" (lazy).
No red error entries.

### Level 2: Completion functional check
```
# Open a Python file in a project with a .venv
nvim src/main.py
# Enter insert mode, type "import "
# Expected: LSP completions appear (pyright modules)
# Type a function name prefix
# Expected: Copilot suggestions appear with " Copilot" label
```

### Level 3: Copilot authentication
```
:Copilot status
```
Expected: `Copilot: Ready` or authentication prompt. If not authenticated: `:Copilot auth`

### Level 4: Capabilities upgrade verification
```
# In a Python file with pyright attached:
:lua print(vim.inspect(vim.lsp.get_clients()[1].server_capabilities.completionProvider))
```
Expected: `snippetSupport = true` in the output (was false before Phase 6).

### Level 5: Startup time check
```bash
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
```
Expected: < 100ms. blink.cmp adds ~5–10ms with `lazy = false`.

### Level 6: Ghost text check
```
# In insert mode with LSP active, navigate to a completion item without accepting
# Expected: dim inline preview of the item appears after the cursor
```

---

## ACCEPTANCE CRITERIA

- [ ] `lua/plugins/completion.lua` exists with all three plugin specs (copilot.lua, blink-copilot dep, blink.cmp)
- [ ] blink.cmp has `lazy = false` and `version = "1.*"`
- [ ] copilot.lua has `suggestion = { enabled = false }` and `panel = { enabled = false }`
- [ ] `lua/plugins/lsp.lua` uses `require("blink.cmp").get_lsp_capabilities()` (no old comment block)
- [ ] `:Lazy` shows no errors
- [ ] Tab/S-Tab navigate completion items; CR accepts; C-space triggers menu
- [ ] LSP completions appear in a Python or Go file
- [ ] Copilot completions appear with "Copilot" kind label (after `:Copilot auth`)
- [ ] `:Copilot status` shows Ready
- [ ] Startup time remains < 100ms
- [ ] `lazy-lock.json` committed after plugins install

---

## COMPLETION CHECKLIST

- [ ] Task 1: `lua/plugins/completion.lua` created
- [ ] Task 2: `lua/plugins/lsp.lua` capabilities line swapped
- [ ] `:Lazy` verified — no errors
- [ ] Completion tested in a real Python/Go file
- [ ] Copilot authenticated and appearing
- [ ] Startup time verified < 100ms
- [ ] `lazy-lock.json` committed

---

## NOTES

**Why `lazy = false` instead of adding blink.cmp as a dep in lsp.lua?**
Adding `"saghen/blink.cmp"` to lsp.lua's `dependencies = {}` would create an invisible cross-file
coupling: the completion spec and the LSP spec would be linked in a non-obvious way. `lazy = false`
is explicit and mirrors the pattern already used by snacks.nvim and rose-pine.

**Why `version = "1.*"` and not latest?**
blink.cmp bundles a Rust binary for fuzzy matching. The `version` field tells lazy.nvim to download
a pre-compiled binary from a GitHub release tag matching the pattern. Without it, lazy.nvim uses the
HEAD commit, which requires a local Rust toolchain and `cargo build --release`. `"1.*"` pins to the
latest 1.x release — stable API, pre-built binary.

**Why `score_offset = 100` on Copilot?**
LSP completions score naturally in the hundreds to thousands range based on fuzzy match quality.
A `score_offset` of 100 ensures Copilot suggestions rank above buffer-word completions but below
on-point LSP matches. Adjust down to 0 if Copilot items feel too prominent.

**Copilot first-time setup:**
On a fresh machine, run `:Copilot auth` after Neovim opens. This opens a browser for GitHub OAuth.
The token persists in `~/.config/github-copilot/` — never committed to the repo.

**blink-copilot vs blink-cmp-copilot:**
There are two Copilot sources for blink.cmp. This plan uses `fang2hou/blink-copilot` (the one in
the PRD's plugin list). The other (`giuxtaposition/blink-cmp-copilot`) uses the deprecated
`copilot.lua` suggestion API. Do not swap them — the module name changes and the opts structure differs.
