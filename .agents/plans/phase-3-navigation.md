# Feature: Phase 3 — Navigation & Git

The following plan should be complete, but validate all lazy.nvim spec patterns and snacks.nvim API calls before implementing. Pay special attention to the `Snacks` global (set by snacks.nvim, not by the user), the which-key v3 spec format, and the gitsigns `on_attach` pattern for buffer-local hunk keymaps.

## Feature Description

Add full navigation and Git integration to ssnvim: snacks.nvim as the central multi-tool hub (fuzzy picker, lazygit float, floating terminal, dashboard, notifier, indent guides), oil.nvim for filesystem navigation, gitsigns.nvim for in-buffer Git decorations and hunk operations, which-key.nvim for keybinding discoverability, and nvim-autopairs for bracket/quote auto-closing. This phase produces two files: `lua/plugins/snacks.lua` and `lua/plugins/editor.lua`.

## User Story

As a developer who relies on fuzzy finding, lazygit, and in-buffer Git hunks to navigate code and manage version control, I want a single-keypress access to file search, live grep, buffer switching, lazygit, and a floating terminal — all organized under discoverable which-key groups — so that I can navigate any project and manage Git without leaving Neovim.

## Problem Statement

Phase 2 produced a beautiful, themed Neovim with a statusline. But there is no way to find files, switch buffers, grep across the project, open lazygit, or see Git signs in the gutter. Pressing `<leader>` shows nothing (which-key is not installed). Opening a directory requires `:e` and manual path typing. Phase 3 closes all of these gaps.

## Solution Statement

Create two files:
1. `lua/plugins/snacks.lua` — single snacks.nvim spec with all modules enabled: picker (with `<leader>f*` keys), lazygit (`<leader>gg`), terminal (`<leader>tt`), dashboard (startup screen), notifier (replaces vim.notify), and indent guides (automatic).
2. `lua/plugins/editor.lua` — four specs: oil.nvim (`-` key), gitsigns.nvim (`<leader>g*` keys via on_attach), which-key.nvim (group registration), nvim-autopairs.

## Feature Metadata

**Feature Type**: New Capability
**Estimated Complexity**: Medium
**Primary Systems Affected**: `lua/plugins/snacks.lua` (new), `lua/plugins/editor.lua` (new)
**Dependencies**: folke/snacks.nvim, stevearc/oil.nvim, lewis6991/gitsigns.nvim, folke/which-key.nvim, windwp/nvim-autopairs

---

## CONTEXT REFERENCES

### Relevant Codebase Files — READ BEFORE IMPLEMENTING

- `lua/plugins/ui.lua` (full file) — canonical reference for the lazy.nvim spec format: comment headers with `── Title ──`, `lazy = false` eager loading, `opts = {}` vs `config = function(_, opts)` distinction, no globals.
- `lua/config/keymaps.lua` (lines 1–4) — confirms: plugin keymaps go in `keys = {}` inside the spec, NOT in this file.
- `lua/config/options.lua` (line 34) — `updatetime = 250` is set; relevant for gitsigns CursorHold responsiveness. Also confirms `signcolumn = "yes"` — do NOT enable snacks.statuscolumn.
- `lua/config/autocmds.lua` (lines 1–14) — augroup naming convention: `ssnvim_<concern>`. Follow this if any Phase 3 plugin requires augroups.
- `init.lua` (lines 32–37) — `spec = { { import = "plugins" } }` auto-imports all `*.lua` files under `lua/plugins/`. No changes needed here.
- `.claude/PRD.md` (§7.1) — canonical snacks.nvim module table with keybindings; use as authoritative spec.

### New Files to Create

- `lua/plugins/snacks.lua` — single snacks.nvim lazy spec
- `lua/plugins/editor.lua` — four specs: oil.nvim, gitsigns.nvim, which-key.nvim, nvim-autopairs

### Files to Modify

None. Phase 3 adds only new files.

---

## ARCHITECTURE DECISIONS

### Why `Snacks` is a global (not a require)

snacks.nvim registers `Snacks` as a Vim global (via `_G.Snacks`) during setup. This means:
- `Snacks.picker.files()` works anywhere after snacks.nvim has loaded
- Do NOT `require("snacks")` inside `keys` lambdas — just use `Snacks` directly
- lua-ls / luacheck will flag `Snacks` as an unknown global — this is expected and cosmetic only

### Why `lazy = false` for snacks.nvim

snacks.nvim's notifier replaces `vim.notify` globally. If it lazy-loads, early startup messages from other plugins bypass snacks and are lost. Loading eagerly ensures all notifications go through snacks.notifier from the start.

### Why `priority = 950` for snacks.nvim

Loads after rose-pine (priority 1000) so the colorscheme is applied before the dashboard renders. Higher than default plugin priority (50) so snacks loads before other eager plugins.

### Why `BufReadPre` for gitsigns

Fires before the buffer is rendered. Signs appear on the first frame — no flash of missing signs. `BufReadPost` would cause a brief flicker.

### Why `VeryLazy` for which-key

which-key only needs to be present when the user presses a key. `VeryLazy` defers it until after initial UI renders, saving startup time. It is still available on the very first keypress.

### Why `lazy = false` for oil.nvim

The `-` key must work from the very first buffer (including the dashboard). If oil lazy-loads via `keys`, the first press triggers the load but does nothing — second press works. Eager loading eliminates this UX friction. oil is small; startup cost is negligible.

### `<leader>fs` and `<leader>fd` — include now, work later

`Snacks.picker.lsp_symbols()` and `Snacks.picker.diagnostics()` open an empty picker before Phase 5 adds LSP — no crash, no errors. The keybindings are registered now so which-key shows them and no keymap changes are needed in Phase 5.

### snacks.lua supersedes nothing

The PRD describes a partial Phase 2 snacks setup (dashboard, indent, notifier). Looking at the actual Phase 2 output, `ui.lua` contains only rose-pine, auto-dark-mode, and lualine — **no snacks.nvim was added in Phase 2**. `snacks.lua` in Phase 3 is the first and only snacks spec. Nothing to remove or merge.

---

## IMPLEMENTATION PLAN

### Step 1: Create `lua/plugins/snacks.lua`

Single lazy.nvim spec for `folke/snacks.nvim`:
- `lazy = false`, `priority = 950`
- `keys = {}` with all picker/lazygit/terminal bindings
- `opts = {}` with all module configs

### Step 2: Create `lua/plugins/editor.lua`

Four specs in order: oil.nvim, gitsigns.nvim, which-key.nvim, nvim-autopairs.

### Step 3: Validate

Headless smoke test + manual validation checklist below.

---

## STEP-BY-STEP TASKS

### TASK 1 — CREATE `lua/plugins/snacks.lua`

- **IMPLEMENT**: Full snacks.nvim spec with all six modules enabled
- **PATTERN**: `lazy = false` + `priority` from `ui.lua:27-36` (rose-pine spec)
- **IMPORTS**: `Snacks` global (no require needed in keys lambdas)
- **GOTCHA**: `Snacks` (capital S) is a global injected by snacks.nvim — do NOT `require("snacks")` in keys
- **GOTCHA**: `priority = 950` (below rose-pine 1000, above default 50) ensures correct load order
- **GOTCHA**: `statuscolumn = { enabled = false }` — options.lua sets `signcolumn = "yes"`; snacks.statuscolumn would override it
- **GOTCHA**: Dashboard `action` field is a string prefixed with `:` or `:lua ` — NOT a Lua function
- **VALIDATE**: `nvim --headless -c "lua print('ok')" -c "qa" 2>&1`

```lua
-- lua/plugins/snacks.lua — snacks.nvim: picker, lazygit, terminal, dashboard, notifier, indent
-- snacks.nvim is a multi-tool by folke. One require("snacks").setup() call enables all modules.
-- The `Snacks` global is injected by snacks.nvim at load time — no require() needed in keys.

return {
  {
    "folke/snacks.nvim",
    -- Eager load: notifier must replace vim.notify before other plugins send notifications.
    -- If lazy-loaded, early startup messages bypass snacks and are lost.
    lazy     = false,
    priority = 950, -- below rose-pine (1000) so colorscheme is applied first

    -- ── Keybindings ──────────────────────────────────────────────────────────
    -- All snacks pickers use the Snacks global (set by snacks.nvim at load time).
    -- <leader>f* = find/pick  |  <leader>g* = git  |  <leader>t* = terminal
    keys = {
      -- Find / pick
      { "<leader>ff", function() Snacks.picker.files()       end, desc = "Find files"        },
      { "<leader>fg", function() Snacks.picker.grep()        end, desc = "Live grep"         },
      { "<leader>fb", function() Snacks.picker.buffers()     end, desc = "Find buffers"      },
      { "<leader>fh", function() Snacks.picker.help()        end, desc = "Find help"         },
      -- Note: lsp_symbols and diagnostics are no-ops until Phase 5 adds LSP.
      -- Include now so which-key shows them and keybindings are stable across phases.
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Find LSP symbols"  },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Find diagnostics"  },
      -- Git
      { "<leader>gg", function() Snacks.lazygit()            end, desc = "Open lazygit"      },
      -- Terminal
      { "<leader>tt", function() Snacks.terminal()           end, desc = "Open terminal"     },
    },

    opts = {
      -- ── Picker ───────────────────────────────────────────────────────────
      -- Fuzzy finder replacing Telescope. Respects .gitignore by default.
      picker = {},

      -- ── Lazygit ──────────────────────────────────────────────────────────
      -- Opens lazygit in a snacks floating window. Requires lazygit on PATH.
      -- Closing the float returns cursor to previous position automatically.
      lazygit = {},

      -- ── Terminal ─────────────────────────────────────────────────────────
      -- Floating terminal shell. Close with the shell `exit` command or <C-d>.
      terminal = {},

      -- ── Dashboard ────────────────────────────────────────────────────────
      -- Shown on bare `nvim` invocation (no file argument).
      -- snacks detects whether a file arg was passed and skips dashboard if so.
      dashboard = {
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
        preset = {
          header = [[ssnvim]],
          keys = {
            { icon = "󰱼", key = "f", desc = "Find File",    action = ":lua Snacks.picker.files()"  },
            { icon = "", key = "r", desc = "Recent Files",  action = ":lua Snacks.picker.recent()" },
            { icon = "", key = "q", desc = "Quit",          action = ":qa"                         },
          },
        },
      },

      -- ── Notifier ─────────────────────────────────────────────────────────
      -- Replaces vim.notify globally. Notifications appear as non-blocking
      -- floating toasts rather than blocking the command line.
      notifier = {},

      -- ── Indent ───────────────────────────────────────────────────────────
      -- Visual indent guides on all buffers. Uses treesitter scope when available
      -- (Phase 4); falls back to indent-level heuristic until then.
      indent = {},

      -- ── Performance modules ──────────────────────────────────────────────
      -- bigfile:   disables expensive features (treesitter, indent) for files > 1.5 MB
      -- quickfile: faster file loading by bypassing some event overhead
      bigfile   = { enabled = true },
      quickfile = { enabled = true },

      -- ── Disabled modules ─────────────────────────────────────────────────
      -- statuscolumn: options.lua sets signcolumn="yes"; snacks.statuscolumn would override it
      -- words:        not needed for MVP
      statuscolumn = { enabled = false },
      words        = { enabled = false },
    },
  },
}
```

---

### TASK 2 — CREATE `lua/plugins/editor.lua`

- **IMPLEMENT**: Four plugin specs: oil.nvim, gitsigns.nvim, which-key.nvim, nvim-autopairs
- **PATTERN**: Same spec format as `ui.lua`; keymaps in `keys = {}` or `on_attach` (gitsigns)
- **IMPORTS**: `package.loaded.gitsigns` inside on_attach (canonical gitsigns pattern)
- **GOTCHA**: `vim.wo.diff` check in `]h`/`[h` — in diff mode, native `]c`/`[c` must be used instead
- **GOTCHA**: which-key v3 uses `spec = { ... }` inside opts, NOT `require("which-key").register()`
- **GOTCHA**: `gs.toggle_current_line_blame` — exact function name; not `toggle_blame` or `blame_line`
- **VALIDATE**: `nvim --headless -c "lua print('ok')" -c "qa" 2>&1`

```lua
-- lua/plugins/editor.lua — oil.nvim, gitsigns, which-key, nvim-autopairs

return {

  -- ── File manager: oil.nvim ───────────────────────────────────────────────
  -- Edits the filesystem like a buffer. `-` opens the parent directory of the
  -- current file. `g?` inside oil shows all oil keybindings.
  -- lazy=false: `-` must work from the first buffer (including dashboard/scratch).
  -- If lazy-loaded via keys, the first press triggers load but does nothing.
  {
    "stevearc/oil.nvim",
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {},  -- oil defaults are sufficient for MVP
  },

  -- ── Git decorations: gitsigns.nvim ──────────────────────────────────────
  -- Shows added/changed/removed line signs in the sign column.
  -- Hunk navigation and operations registered per-buffer via on_attach.
  -- BufReadPre: attach before buffer renders so signs appear on the first frame.
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },

      -- on_attach: buffer-local keymaps — only active in Git-tracked buffers.
      -- Defined here (not in keymaps.lua) so they don't pollute non-git buffers.
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Hunk navigation — mirrors ]d/[d diagnostic navigation convention.
        -- vim.wo.diff guard: in diff mode, use native ]c/[c instead of gitsigns.
        vim.keymap.set("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.next_hunk()
          end
        end, { buffer = bufnr, desc = "Next hunk" })

        vim.keymap.set("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.prev_hunk()
          end
        end, { buffer = bufnr, desc = "Prev hunk" })

        -- Hunk operations (<leader>g* — git group)
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk,                { buffer = bufnr, desc = "Stage hunk"        })
        vim.keymap.set("n", "<leader>gr", gs.reset_hunk,                { buffer = bufnr, desc = "Reset hunk"        })
        vim.keymap.set("n", "<leader>gp", gs.preview_hunk,              { buffer = bufnr, desc = "Preview hunk"      })
        vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle line blame" })

        -- Visual-mode partial hunk staging/reset (operate on selected lines only)
        vim.keymap.set("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { buffer = bufnr, desc = "Stage hunk (visual)" })

        vim.keymap.set("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { buffer = bufnr, desc = "Reset hunk (visual)" })
      end,
    },
  },

  -- ── Keybinding discovery: which-key.nvim ────────────────────────────────
  -- Displays available keybindings when a prefix key is held.
  -- VeryLazy: no need to load before first render; saves startup time.
  -- Uses which-key v3 spec format — do NOT use the v2 register() API.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      -- Register group names for all <leader>* prefix groups.
      -- <leader>l and <leader>c groups are defined here even though their keymaps
      -- are added in Phase 5 (LSP) and Phase 7 (format/lint) respectively.
      -- which-key shows the group label; individual keymaps populate it later.
      spec = {
        { "<leader>f", group = "find"     },
        { "<leader>g", group = "git"      },
        { "<leader>t", group = "terminal" },
        { "<leader>l", group = "lsp"      },  -- keymaps added in Phase 5 (LspAttach)
        { "<leader>c", group = "code"     },  -- keymaps added in Phase 7 (format/lint)
      },
    },
  },

  -- ── Auto-close brackets and quotes: nvim-autopairs ──────────────────────
  -- Inserts closing bracket/quote/paren when the opening one is typed.
  -- InsertEnter: only active in insert mode; never needed in normal mode.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = {},  -- defaults handle all common pairs: ()[]{}"'`
  },

}
```

---

## KNOWN GOTCHAS

| # | Gotcha | Mitigation |
|---|---|---|
| 1 | `Snacks` global — lua-ls/luacheck flags it as undefined | Expected and cosmetic; add `---@diagnostic disable-next-line: undefined-global` or configure in Phase 8 |
| 2 | Dashboard `action` must be a string (`:` or `:lua `) | Do NOT use a Lua function value in the action field |
| 3 | `package.loaded.gitsigns` in on_attach | Canonical pattern from gitsigns README; avoids redundant require |
| 4 | `vim.wo.diff` check in `]h`/`[h` | Required for correct behavior in `:diffthis` diff mode |
| 5 | which-key v3: use `opts.spec`, NOT `require("which-key").register()` | v2 register() still works but logs deprecation warning |
| 6 | `<leader>fs`/`<leader>fd` before LSP | Empty picker, not an error — correct intentional behavior |
| 7 | oil.nvim must be `lazy = false` | Keys-based lazy loading causes silent first-press failure |
| 8 | Do NOT set `snacks.statuscolumn = {}` | options.lua manages signcolumn; snacks would override it |

---

## TESTING STRATEGY

No automated test framework. All validation is manual plus headless smoke tests.

### Manual Validation Checklist

1. **Dashboard** — `nvim` (no args): ssnvim dashboard shows find/recent/quit items
2. **Picker: files** — `<leader>ff`: fuzzy file finder opens
3. **Picker: grep** — `<leader>fg`: live grep with live results
4. **Picker: buffers** — `<leader>fb`: shows open buffers
5. **Picker: help** — `<leader>fh`: searches Neovim help
6. **Picker: LSP symbols** — `<leader>fs`: opens picker (empty, no crash)
7. **Picker: diagnostics** — `<leader>fd`: opens picker (empty, no crash)
8. **Lazygit** — `<leader>gg`: lazygit float opens (requires lazygit on PATH)
9. **Terminal** — `<leader>tt`: floating terminal opens
10. **Notifier** — `:lua vim.notify("test")`: snacks toast appears (not cmdline message)
11. **Indent guides** — open a nested file: indent guide lines visible
12. **Oil** — press `-`: parent directory opens as an editable buffer
13. **Gitsigns signs** — open a file in a Git repo: add/change/delete signs in sign column
14. **Gitsigns hunk nav** — `]h`/`[h`: navigate between hunks
15. **Gitsigns preview** — `<leader>gp`: hunk preview float
16. **Gitsigns blame** — `<leader>gb`: inline blame annotation toggles
17. **Gitsigns stage** — `<leader>gs`: stage hunk (verify with `:Gitsigns status`)
18. **Which-key** — `<leader>` + pause: popup shows `f find`, `g git`, `t terminal`, `l lsp`, `c code`
19. **Autopairs** — insert mode, type `(`: `)` auto-inserted, cursor between them
20. **No errors** — `:checkhealth snacks` and `:checkhealth lazy`: no ERRORs

---

## VALIDATION COMMANDS

### Level 1: Lua Syntax

```bash
luac -p lua/plugins/snacks.lua && luac -p lua/plugins/editor.lua
# Expected: silent (no output = no syntax errors)
```

### Level 2: Headless Launch

```bash
nvim --headless -c "lua print('ok')" -c "qa" 2>&1
# Expected: "ok" with no error output
```

### Level 3: Plugin Health

```bash
nvim --headless -c "checkhealth snacks" -c "qa" 2>&1
# Expected: no ERROR lines
```

### Level 4: Startup Time

```bash
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
# Goal: < 100ms total
# Phase 3 adds ~5 plugins; expect 5–15ms additional overhead vs Phase 2 baseline
```

---

## ACCEPTANCE CRITERIA

- [ ] `lua/plugins/snacks.lua` created — valid single-spec lazy.nvim table
- [ ] `lua/plugins/editor.lua` created — valid four-spec lazy.nvim table
- [ ] `nvim` (no args) shows ssnvim dashboard with find/recent/quit
- [ ] `<leader>ff` opens snacks file picker
- [ ] `<leader>fg` opens snacks live grep
- [ ] `<leader>fb` opens snacks buffer picker
- [ ] `<leader>fh` opens snacks help picker
- [ ] `<leader>fs` opens snacks picker (empty until LSP; no error)
- [ ] `<leader>fd` opens snacks picker (empty until LSP; no error)
- [ ] `<leader>gg` opens lazygit float
- [ ] `<leader>tt` opens floating terminal
- [ ] `vim.notify("test")` shows a snacks toast notification
- [ ] Indent guides visible on nested code
- [ ] `-` key opens oil.nvim parent directory buffer
- [ ] Git signs appear in sign column for Git-tracked files
- [ ] `]h`/`[h` navigate between hunks
- [ ] `<leader>gp` shows gitsigns hunk preview float
- [ ] `<leader>gb` toggles git blame annotation
- [ ] `<leader>gs` stages current hunk
- [ ] `<leader>gr` resets current hunk
- [ ] `<leader>` + pause shows which-key popup with all five groups
- [ ] Typing `(` in insert mode auto-inserts `)` with cursor between them
- [ ] `:checkhealth lazy` — no ERRORs
- [ ] `:checkhealth snacks` — no ERRORs
- [ ] Startup time < 100ms

---

## COMPLETION CHECKLIST

- [ ] Task 1: `lua/plugins/snacks.lua` created
- [ ] Task 2: `lua/plugins/editor.lua` created
- [ ] Lua syntax checked (`luac -p`)
- [ ] All acceptance criteria above checked off
- [ ] `:Lazy sync` run inside Neovim to install Phase 3 plugins
- [ ] `lazy-lock.json` updated and committed as part of Phase 3 commit
- [ ] Startup time verified < 100ms

---

## NOTES

**Plugin count after Phase 3:** Phase 2 had 4 plugins. Phase 3 adds 5 (snacks, oil, gitsigns, which-key, autopairs) = 9 total. Final MVP target: 19.

**lazy-lock.json discipline:** After `:Lazy sync` installs Phase 3 plugins, commit `lazy-lock.json` immediately. snacks.nvim's API changes frequently — pinning to a commit is critical.

**lazygit requirement:** `<leader>gg` requires `lazygit` installed and on PATH. If not found, snacks shows a notification error (not a Neovim crash). Document as prerequisite in Phase 8 README.

**which-key group icons:** `spec` entries can include `icon = "..."` for popup icons. Deferred to Phase 8 polish — out of scope for MVP.

**Confidence score: 9/10** — All five plugins have stable APIs. Primary risks: (1) snacks.nvim dashboard `preset` API is the most volatile part of the library — mitigated by `lazy-lock.json`; (2) exact name of `Snacks.picker.recent()` should be verified against snacks source if any doubt — alternatives seen in the wild include `picker.recentfiles` and `picker.recent`.
