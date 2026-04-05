# Feature: Config Cleanup and Missing Features

The following plan should be complete, but validate codebase patterns and documentation before
implementing. Pay special attention to the order of tasks — `init.lua` cleanup must happen
AFTER the destination files have been updated to receive the moved code.

## Feature Description

Five distinct gaps exist between the current implementation and a fully PRD-compliant ssnvim
configuration. They fall into two categories:

- **Structural violations**: code leaked into `init.lua` that belongs in plugin spec files;
  a duplicate autocmd; a duplicate keymap; a dead `lualine.setup()` call.
- **Missing features**: `linting.lua` (nvim-lint) is absent; `yaml.github-actions` filetype
  detection is absent (blocking `gh_actions_ls` from ever attaching); `nvim-autopairs` is absent;
  K8s context component is missing from lualine; `<leader>c` and `<leader>l` which-key groups
  are undeclared.

## User Story

As a developer using ssnvim daily across Go, Python, shell, YAML, Helm, and GitHub Actions,
I want every plugin configured in its proper spec file, every linter wired up, and every
LSP server attaching to the correct filetypes,
so that the config is correct, maintainable, and exactly matches the PRD.

## Problem Statement

1. `init.lua` (lines 41–126) contains treesitter keymaps, format commands, and a duplicate
   FileType autocmd — all of which belong in their respective plugin files. This violates the
   architectural rule that `init.lua` may only contain the lazy.nvim bootstrap and
   `require("config")`.
2. `lua/plugins/linting.lua` does not exist. `nvim-lint` is missing entirely — no async linting
   for Go, shell, or YAML.
3. `autocmds.lua` has no `vim.filetype.add()` pattern for `.github/workflows/*.{yml,yaml}`.
   `gh_actions_ls` in `lsp.lua` declares `filetypes = { "yaml.github-actions" }`, but Neovim
   will never assign that filetype, so the server never attaches.
4. `ui.lua` calls `require("lualine").setup()` twice (lines 180–196 and line 197). The first
   call is immediately overridden and is dead code. Neither call includes a K8s context component.
5. `editor.lua` which-key spec is missing `<leader>c` (code) and `<leader>l` (LSP) group labels.
   `lsp.lua` uses `<leader>l*` keymaps with a comment saying "group is already registered in
   editor.lua" — but it is not.
6. `nvim-autopairs` is listed in the PRD and CLAUDE.md plugin table but is absent from
   `editor.lua` and `lazy-lock.json`.

## Solution Statement

Execute six targeted tasks in dependency order:

1. Add `<leader>c` and `<leader>l` which-key groups to `editor.lua` and add `nvim-autopairs`
   spec (no `init.lua` changes yet — destination files must be ready first).
2. Move treesitter textobject keymaps from `init.lua` into `treesitter.lua`'s config function.
3. Move `FormatDisable`/`FormatEnable` commands and format keymaps from `init.lua` into
   `formatting.lua`.
4. Strip `init.lua` of all code moved in tasks 2–3 plus the duplicate FileType autocmd.
5. Create `lua/plugins/linting.lua` with the full `nvim-lint` spec.
6. Add `yaml.github-actions` filetype detection to `autocmds.lua`.
7. Fix `ui.lua`: remove dead first `lualine.setup()` call, add K8s context component to the
   surviving custom lualine config.

## Feature Metadata

**Feature Type**: Refactor + Bug Fix + New Capability
**Estimated Complexity**: Medium
**Primary Systems Affected**:
  `init.lua`, `lua/config/autocmds.lua`, `lua/plugins/editor.lua`,
  `lua/plugins/treesitter.lua`, `lua/plugins/formatting.lua`, `lua/plugins/linting.lua` (new),
  `lua/plugins/ui.lua`
**Dependencies**: `mfussenegger/nvim-lint` (new), `windwp/nvim-autopairs` (new)

---

## CONTEXT REFERENCES

### Relevant Codebase Files — MUST READ BEFORE IMPLEMENTING

- `init.lua` (lines 41–126) — all code to be moved or deleted. Read in full before touching.
- `lua/plugins/editor.lua` (lines 38–66) — which-key `opts.spec` table; `<leader>c` and
  `<leader>l` groups must be added here following the same `{ "<leader>x", group = "name" }`
  format already used for `<leader>f`, `<leader>g`, `<leader>t`, `<leader>u`.
- `lua/plugins/treesitter.lua` (lines 33–57) — `nvim-treesitter-textobjects` spec; the
  textobject keymaps from `init.lua:41–75` must be appended inside this spec's
  `config = function()` block, after the existing `require(...).setup({...})` call.
- `lua/plugins/formatting.lua` (lines 1–61) — `conform.nvim` spec; `FormatDisable`/`FormatEnable`
  user commands and the `<leader>uf`, `<leader>cn`, `<leader>cf`, `<leader>cF` keymaps from
  `init.lua:88–126` must be added into this spec's `config = function()` (replacing the current
  `opts = {}` approach — a `config` function is needed to also create user commands).
  **CRITICAL**: `formatting.lua` already declares `<leader>cf` in its `keys = {}` table
  (line 10–15). When moving the keymaps from `init.lua`, remove the duplicate `keys` entry from
  `formatting.lua` and put ALL four keymaps inside the new `config` function instead.
- `lua/config/autocmds.lua` (lines 1–11) — existing `vim.filetype.add()` call for Helm patterns;
  the GitHub Actions pattern must be added to the same call (same table, new keys).
- `lua/config/autocmds.lua` (lines 64–73) — the `FileType` treesitter autocmd that already
  exists here. The identical copy at `init.lua:77–86` must be deleted, NOT this one.
- `lua/plugins/ui.lua` (lines 52–198) — full lualine `config = function()`. The dead first
  `lualine.setup()` call is at lines 180–196; the live call is at line 197. The `ins_right`
  section (lines 145–178) is where the K8s context component should be inserted, before
  the existing `ins_right` entries.
- `lua/plugins/lsp.lua` (lines 173–176) — `gh_actions_ls` config confirms it expects
  `filetypes = { "yaml.github-actions" }`. This validates that our filetype detection target
  string is correct.
- `.agents/plans/phase-7-format-lint.md` (lines 240–300) — contains the complete, validated
  `linting.lua` implementation spec including exact linter names (`golangci_lint` not
  `golangci-lint`). Use this as the source of truth for Task 5.

### New Files to Create

- `lua/plugins/linting.lua` — `mfussenegger/nvim-lint` spec with `linters_by_ft` and
  `BufWritePost`/`BufReadPost` autocmd trigger.

### Files to Edit (in execution order)

1. `lua/plugins/editor.lua` — add which-key groups + nvim-autopairs spec
2. `lua/plugins/treesitter.lua` — receive textobject keymaps from `init.lua`
3. `lua/plugins/formatting.lua` — receive FormatDisable/Enable commands + keymaps from `init.lua`
4. `init.lua` — remove lines 41–126 (now fully moved/deleted)
5. `lua/plugins/linting.lua` — CREATE (new file)
6. `lua/config/autocmds.lua` — add `yaml.github-actions` filetype pattern
7. `lua/plugins/ui.lua` — remove dead lualine.setup(), add K8s context component

### Relevant Documentation — READ BEFORE IMPLEMENTING

- [nvim-lint README — Usage](https://github.com/mfussenegger/nvim-lint#usage)
  - Section: `linters_by_ft` table, `try_lint()`, autocmd setup pattern
  - Why: nvim-lint has no `setup()` — `config = function()` is mandatory
- [nvim-lint — Linters list](https://github.com/mfussenegger/nvim-lint#available-linters)
  - **CRITICAL**: `golangci_lint` (underscore), not `golangci-lint` (hyphen)
- [nvim-autopairs README](https://github.com/windwp/nvim-autopairs#installation)
  - Section: basic setup — `opts = {}` is sufficient; no complex config needed for MVP
- [vim.filetype.add() docs](https://neovim.io/doc/user/lua.html#vim.filetype.add())
  - Section: `pattern` table — keys are Lua patterns matched against the full file path
- [which-key v3 spec format](https://github.com/folke/which-key.nvim#%EF%B8%8F-mappings)
  - Section: group spec — `{ "<leader>x", group = "name" }` (NOT v2 `register()` API)

---

## PATTERNS TO FOLLOW

### which-key group registration (from `editor.lua:59-63`)

```lua
-- Add to opts.spec table — exact same shape as existing entries:
{ "<leader>f", group = "find" },
{ "<leader>g", group = "git" },
-- New entries follow the same pattern:
{ "<leader>c", group = "code" },
{ "<leader>l", group = "lsp" },
```

### config = function() for imperative setup (from `treesitter.lua:36-57`, `lsp.lua:46-215`)

```lua
config = function()
  local thing = require("plugin-name")
  thing.setup({ ... })
  -- imperative setup, keymaps, autocmds here
end,
```

### Augroup naming convention (from `autocmds.lua:14`, `lsp.lua:65`)

```lua
local group = vim.api.nvim_create_augroup("ssnvim_{name}", { clear = true })
```

### vim.filetype.add pattern keys (from `autocmds.lua:4-11`)

```lua
vim.filetype.add({
  pattern = {
    -- Existing helm patterns:
    [".*/templates/.*%.yaml"] = "helm",
    -- New GitHub Actions pattern — must anchor to .github/workflows/:
    [".github/workflows/.*%.ya?ml"] = "yaml.github-actions",
  },
})
```
Note: `%.ya?ml` matches both `.yml` and `.yaml` in a single pattern.
Note: The pattern is matched against the FULL file path (see `:h vim.filetype.add`).

### K8s context lualine component (cached io.popen)

```lua
-- Place BEFORE existing ins_right() calls in ui.lua config function.
-- Cache result to avoid calling kubectl on every statusline redraw.
local _k8s_ctx_cache = nil
local _k8s_ctx_time = 0
local function k8s_context()
  local now = vim.loop.now()
  if _k8s_ctx_cache and (now - _k8s_ctx_time) < 10000 then
    return _k8s_ctx_cache
  end
  local handle = io.popen("kubectl config current-context 2>/dev/null")
  if handle then
    local result = handle:read("*l")
    handle:close()
    _k8s_ctx_cache = result or ""
    _k8s_ctx_time = now
    return _k8s_ctx_cache
  end
  return ""
end

ins_right({
  k8s_context,
  icon = "󱃾",  -- kubernetes icon
  cond = function() return k8s_context() ~= "" end,
  color = ayuline.styles["location"], -- reuse an existing ayu lualine style
})
```
**GOTCHA**: `io.popen` is synchronous. Caching with a 10s TTL (`vim.loop.now()` returns ms)
prevents blocking every redraw. CLAUDE.md explicitly says: "do not call io.popen on every
statusline redraw." The 10000ms (10s) TTL is the right value.

### Comment style (from `lsp.lua`, `editor.lua`)

```lua
-- ── Section header ───────────────────────────────────────────────────────
-- One-line explanation of why, not what.
```

---

## IMPLEMENTATION PLAN

### Phase A: Prepare destination files (tasks 1–3)

Add which-key groups, nvim-autopairs, textobject keymaps, and format commands to their correct
homes BEFORE touching `init.lua`. This ensures no functionality is lost during the transition.

### Phase B: Clean `init.lua` (task 4)

Only after all destination files are updated, strip `init.lua` of everything below line 38.
The result should be exactly: leader setup, lazy bootstrap, `require("config")`, `lazy.setup()`.

### Phase C: New capability files (tasks 5–7)

Create `linting.lua`, patch `autocmds.lua` for filetype detection, fix and extend `ui.lua`.

---

## STEP-BY-STEP TASKS

---

### TASK 1: UPDATE `lua/plugins/editor.lua` — add which-key groups + nvim-autopairs

**IMPLEMENT**:

Add two which-key group entries to `opts.spec` immediately after the existing `<leader>u` entry:
```lua
{ "<leader>c", group = "code" },
{ "<leader>l", group = "lsp" },
```

Add `nvim-autopairs` as a new spec in the return table (after the which-key spec):
```lua
-- ── Auto-close brackets and quotes: nvim-autopairs ──────────────────────
-- Pairs are inserted on the character that opens them, so VeryLazy is fine.
{
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {},
},
```

**PATTERN**: `editor.lua:59-63` — which-key spec array entries.
**PATTERN**: `editor.lua:6-16` — plugin spec format with `event` and `opts = {}`.
**GOTCHA**: Do NOT use `lazy = false` for autopairs — `event = "InsertEnter"` is the correct
trigger so it loads only when the user enters insert mode.
**GOTCHA**: Do NOT add `dependencies` for autopairs — it has none required for basic use.
**VALIDATE**: `:lua require("which-key").show("<leader>c")` → shows "code" group label.
**VALIDATE**: Open any buffer, enter insert mode, type `(` → `)` is auto-inserted.

---

### TASK 2: UPDATE `lua/plugins/treesitter.lua` — receive textobject keymaps from `init.lua`

**IMPLEMENT**:

The `nvim-treesitter-textobjects` spec (lines 33–57) currently ends its `config = function()` at
line 55 with `})` then `end,`. The textobject select and move keymaps from `init.lua:41-75` must
be appended inside that `config` function AFTER the existing `setup({...})` call.

Replace the closing `end,` of the textobjects `config` with the following (note: the setup call
stays, keymaps are appended before the final `end,`):

```lua
config = function()
  require("nvim-treesitter-textobjects").setup({
    select = {
      enable = true,
      lookahead = true,
      selection_modes = {
        ["@parameter.outer"] = "v",
        ["@function.outer"] = "V",
        ["@class.outer"] = "<c-v>",
      },
      include_surrounding_whitespace = false,
    },
    move = {
      enable = true,
      set_jumps = true,
    },
  })

  -- ── Select keymaps ───────────────────────────────────────────────────
  local sel = require("nvim-treesitter-textobjects.select")
  for _, map in ipairs({
    { { "x", "o" }, "af", "@function.outer" },
    { { "x", "o" }, "if", "@function.inner" },
    { { "x", "o" }, "ac", "@class.outer" },
    { { "x", "o" }, "ic", "@class.inner" },
    { { "x", "o" }, "aa", "@parameter.outer" },
    { { "x", "o" }, "ia", "@parameter.inner" },
    { { "x", "o" }, "ad", "@comment.outer" },
    { { "x", "o" }, "as", "@statement.outer" },
  }) do
    vim.keymap.set(map[1], map[2], function()
      sel.select_textobject(map[3], "textobjects")
    end, { desc = "Select " .. map[3] })
  end

  -- ── Move keymaps ─────────────────────────────────────────────────────
  local mv = require("nvim-treesitter-textobjects.move")
  for _, map in ipairs({
    { { "n", "x", "o" }, "]m", mv.goto_next_start,     "@function.outer" },
    { { "n", "x", "o" }, "[m", mv.goto_previous_start, "@function.outer" },
    { { "n", "x", "o" }, "]]", mv.goto_next_start,     "@class.outer" },
    { { "n", "x", "o" }, "[[", mv.goto_previous_start, "@class.outer" },
    { { "n", "x", "o" }, "]M", mv.goto_next_end,       "@function.outer" },
    { { "n", "x", "o" }, "[M", mv.goto_previous_end,   "@function.outer" },
    { { "n", "x", "o" }, "]o", mv.goto_next_start,     { "@loop.inner", "@loop.outer" } },
    { { "n", "x", "o" }, "[o", mv.goto_previous_start, { "@loop.inner", "@loop.outer" } },
  }) do
    local modes, lhs, fn, query = map[1], map[2], map[3], map[4]
    local qstr = (type(query) == "table") and table.concat(query, ",") or query
    vim.keymap.set(modes, lhs, function()
      fn(query, "textobjects")
    end, { desc = "Move to " .. qstr })
  end
end,
```

**PATTERN**: `treesitter.lua:36-57` — existing `config = function()` in the same spec.
**PATTERN**: `init.lua:41-75` — exact code being moved (copy verbatim, do not alter logic).
**GOTCHA**: The `init = function()` block with `vim.g.no_plugin_maps = true` (line 36-38) stays
unchanged — it prevents the plugin from installing its own default maps at startup. The keymaps
we're adding are our OWN explicit maps defined inside `config`, which is fine.
**GOTCHA**: `require("nvim-treesitter-textobjects.select")` and `.move` are called inside `config`
(lazy-loaded after the plugin is ready). In `init.lua` they were called at top level after
`lazy.setup()` — which happened to work, but moving them into `config` is architecturally correct.
**VALIDATE**: Open a Lua or Python file, press `vaf` → entire function selected.
**VALIDATE**: Press `]m` → cursor jumps to next function start.

---

### TASK 3: UPDATE `lua/plugins/formatting.lua` — receive FormatDisable/Enable + keymaps

**IMPLEMENT**:

The current `formatting.lua` uses `opts = {}` pattern. This must be converted to
`config = function()` because we now need to also create user commands. The `keys = {}` table
(currently lines 8–16) must be REMOVED — all keymaps will live inside `config` instead.

Replace the entire file content with:

```lua
-- lua/plugins/formatting.lua — format-on-save runner
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },

    config = function()
      require("conform").setup({
        -- ── Per-filetype formatters ────────────────────────────────────────
        formatters_by_ft = {
          lua    = { "stylua" },
          go     = { "goimports", "gofmt", stop_after_first = true },
          python = { "ruff_format", "black", stop_after_first = true },
          json   = { "biome", "prettier", stop_after_first = true },
          markdown = { "prettier" },
          css    = { "prettier" },
          html   = { "prettier" },
          toml   = { "taplo" },
          sh     = { "shfmt" },
          bash   = { "shfmt" },
          zsh    = { "shfmt" },
        },
        formatters = {
          biome = { require_cwd = true },
        },
        default_format_opts = {
          lsp_format = "fallback",
        },

        -- ── Format on save ────────────────────────────────────────────────
        -- Runs synchronously before BufWritePre completes (blocking, but fast).
        -- lsp_format = "fallback": if no conform formatter is configured for the
        -- current filetype, ask the LSP server to format instead.
        format_on_save = function(bufnr)
          local ignore_filetypes = { "sql", "yaml", "yml" }
          if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
            return
          end
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match("/node_modules/") then
            return
          end
          return { timeout_ms = 500, lsp_format = "fallback" }
        end,
      })

      -- ── FormatDisable / FormatEnable user commands ────────────────────
      -- Bang variant (!): buffer-local disable. Without bang: global disable.
      vim.api.nvim_create_user_command("FormatDisable", function(opts)
        if opts.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
        vim.notify("Autoformat disabled" .. (opts.bang and " (buffer)" or " (global)"), vim.log.levels.WARN)
      end, { desc = "Disable autoformat-on-save", bang = true })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
        vim.notify("Autoformat enabled", vim.log.levels.INFO)
      end, { desc = "Re-enable autoformat-on-save" })

      -- ── Format keymaps ────────────────────────────────────────────────
      local auto_format = true
      vim.keymap.set("n", "<leader>uf", function()
        auto_format = not auto_format
        if auto_format then
          vim.cmd("FormatEnable")
        else
          vim.cmd("FormatDisable")
        end
      end, { desc = "Toggle Autoformat" })

      vim.keymap.set({ "n", "v" }, "<leader>cn", "<cmd>ConformInfo<cr>", { desc = "Conform Info" })

      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        require("conform").format({ async = true }, function(err, did_edit)
          if not err and did_edit then
            vim.notify("Code formatted", vim.log.levels.INFO, { title = "Conform" })
          end
        end)
      end, { desc = "Format buffer" })

      vim.keymap.set({ "n", "v" }, "<leader>cF", function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end, { desc = "Format Injected Langs" })
    end,
  },
}
```

**PATTERN**: `lsp.lua:46-215` — large `config = function()` with setup + user commands + keymaps.
**PATTERN**: `init.lua:88-126` — exact commands and keymaps being moved (copy verbatim).
**GOTCHA**: The current `formatting.lua` has a `keys = {}` table declaring `<leader>cf`. That
entry MUST be removed when switching to `config = function()` — otherwise `<leader>cf` will be
registered twice (once via `keys` at plugin load time, once via `vim.keymap.set` in `config`).
**GOTCHA**: `auto_format` is a module-local variable. Declaring it inside `config = function()`
is correct — it persists for the lifetime of the Neovim session after the plugin loads.
**GOTCHA**: Keep the existing `formatters_by_ft` entries from `formatting.lua` (they have more
entries than `init.lua`). Do NOT use the leaner version from `phase-7-format-lint.md`.
**VALIDATE**: `:ConformInfo` in a Go buffer → shows `goimports` as active formatter.
**VALIDATE**: `<leader>uf` → notification "Autoformat disabled (global)" appears.
**VALIDATE**: `<leader>cf` in a Lua buffer → buffer formats, notification "Code formatted" appears.
**VALIDATE**: `:FormatDisable!` → `vim.b.disable_autoformat` is true; save does not format.

---

### TASK 4: CLEAN `init.lua` — remove all moved/duplicate code

**IMPLEMENT**:

After tasks 1–3 are complete and validated, delete everything from `init.lua` at line 40 onwards.
The final file must contain exactly and only:

```lua
-- ── SSNvim entry point ───────────────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ── Bootstrap lazy.nvim ───────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ── Load config modules ───────────────────────────────────────────────────
require("config")

-- ── Initialise lazy.nvim ──────────────────────────────────────────────────
require("lazy").setup({
  spec = { { import = "plugins" } }, -- loads all specs from lua/plugins/**/*.lua
  defaults = { lazy = true }, -- all plugins lazy by default; opt-out per spec
  install = { colorscheme = { "default" } }, -- safe fallback before rose-pine is installed
  checker = { enabled = false }, -- no automatic update checks
})
```

**PATTERN**: CLAUDE.md — "init.lua is kept minimal — it bootstraps lazy.nvim and sources the
three config/ modules."
**GOTCHA**: The FileType autocmd at `init.lua:77-86` is a duplicate of `autocmds.lua:64-73`.
Delete it from `init.lua`; do NOT delete the copy in `autocmds.lua`.
**GOTCHA**: The `<leader>cf` keymap at `init.lua:116-122` is duplicated. After task 3, it lives
in `formatting.lua`'s `config` function. Delete the `init.lua` copy entirely.
**VALIDATE**: `nvim --headless -c "lua print('ok')" -c "qa"` exits with no error.
**VALIDATE**: `nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log`
  → startup time still < 100ms.
**VALIDATE**: Open Neovim normally, press `<leader>cf` → formats. Press `vaf` → selects function.

---

### TASK 5: CREATE `lua/plugins/linting.lua`

**IMPLEMENT**:

```lua
-- lua/plugins/linting.lua — async linting runner
-- nvim-lint surfaces linter output as vim.diagnostic entries without an LSP server.
-- Python excluded: ruff LSP (lsp.lua) already provides diagnostics — no duplicates.
-- Helm excluded: helm_ls provides template diagnostics.
-- All binaries already installed by mason.nvim in lsp.lua (golangci-lint, shellcheck, yamllint,
-- actionlint).

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },

    -- nvim-lint has no setup() that accepts a config table.
    -- linters_by_ft must be assigned directly on the module; autocmd wires the trigger.
    -- config = function() is REQUIRED — opts = {} alone does nothing useful.
    config = function()
      local lint = require("lint")

      -- ── Per-filetype linters ──────────────────────────────────────────
      -- Key: vim filetype string (same as vim.bo.filetype).
      -- Value: list of linter names — must match filenames in nvim-lint's lua/lint/linters/.
      -- IMPORTANT: underscore names only. golangci_lint NOT golangci-lint.
      lint.linters_by_ft = {
        go   = { "golangci_lint" },
        sh   = { "shellcheck" },
        bash = { "shellcheck" },
        zsh  = { "shellcheck" },
        yaml = { "yamllint" },
        ["yaml.github-actions"] = { "actionlint" },
      }

      -- ── Lint trigger ─────────────────────────────────────────────────
      -- BufReadPost: lint when a file is opened (shows existing issues immediately).
      -- BufWritePost: lint after every save (picks up new issues instantly).
      -- try_lint() is non-blocking; it fires the linter and callbacks update diagnostics
      -- asynchronously — it does not block typing or saving.
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

**PATTERN**: `treesitter.lua:36-57` — `config = function()` with imperative module setup.
**PATTERN**: `autocmds.lua:13-21` — augroup naming `ssnvim_{name}` and autocmd registration.
**PATTERN**: `.agents/plans/phase-7-format-lint.md:258-286` — validated linting.lua spec.
**GOTCHA**: `golangci_lint` (underscore) is the nvim-lint internal name. The Mason package is
`golangci-lint` (hyphen). They are different name spaces. Using the wrong one silently disables
the linter with no error.
**GOTCHA**: `yaml.github-actions` is a valid filetype string for `linters_by_ft` — Lua table
keys can be any string using bracket notation. `actionlint` requires the `yaml.github-actions`
filetype to be set (Task 6 handles this).
**GOTCHA**: `try_lint()` with no args uses `vim.bo.filetype` to pick linters. For a buffer with
no entry in `linters_by_ft` it is a safe no-op.
**VALIDATE**: `:lua print(vim.inspect(require("lint").linters_by_ft))` → all five filetypes listed.
**VALIDATE**: Open a YAML file with intentional indentation error → yamllint diagnostic in sign
column within seconds of opening.
**VALIDATE**: Open a shell script with `[ $var ]` (unquoted) → shellcheck diagnostic appears.

---

### TASK 6: UPDATE `lua/config/autocmds.lua` — add yaml.github-actions filetype detection

**IMPLEMENT**:

Append the GitHub Actions pattern to the existing `vim.filetype.add()` call (lines 4–11).
The existing `pattern` table gains one new key:

```lua
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.yml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    ["helmfile.*%.yaml"] = "helm",
    -- GitHub Actions workflow files — sets ft=yaml.github-actions so gh_actions_ls attaches.
    -- Pattern matches the full absolute file path; anchoring to .github/workflows/ is enough.
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.github-actions",
  },
})
```

**PATTERN**: `autocmds.lua:4-11` — existing `vim.filetype.add()` call being extended.
**PATTERN**: `lsp.lua:173-176` — confirms the target filetype string is `yaml.github-actions`.
**GOTCHA**: In `vim.filetype.add()` patterns the key is a Lua pattern matched against the FULL
absolute file path. The leading `.*` is required to match anywhere in the path. The dot in
`.github` must be escaped as `%.github` (Lua pattern, not glob).
**GOTCHA**: `%.ya?ml` matches both `.yml` (`a` is optional via `?`) and `.yaml` in a single
pattern. Do not add two separate patterns.
**GOTCHA**: This single change is what gates `gh_actions_ls`, the treesitter `gh_actions_expressions`
grammar (already installed in `treesitter.lua:29`), AND `actionlint` in `linting.lua`. All three
are already configured — only this filetype detection was missing.
**VALIDATE**: `nvim .github/workflows/some-workflow.yml` → `:set ft?` shows `yaml.github-actions`.
**VALIDATE**: In a workflow file → `gh_actions_ls` attaches (`:LspInfo` shows it connected).
**VALIDATE**: In a workflow file with a syntax error → actionlint diagnostic appears.

---

### TASK 7: UPDATE `lua/plugins/ui.lua` — remove dead lualine.setup(), add K8s context

**IMPLEMENT**:

The `lualine` spec `config = function()` (lines 52–198) has two problems:
1. Lines 180–196 contain a dead `require("lualine").setup({...})` call that is immediately
   overridden by line 197 `require("lualine").setup(lualine_config)`. Delete lines 180–196.
2. No K8s context component exists. Add the cached component using `ins_right()` BEFORE the
   existing `ins_right` block.

**Step A — delete dead lualine.setup() call (lines 180–196):**

The block to delete is:
```lua
			require("lualine").setup({
				options = {
					icons_enabled = true,
					-- Disable sections and component separators
					component_separators = "",
					section_separators = "",
					theme = "auto",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } }, -- path=1 → show relative path
					lualine_x = { "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
```
Delete this entire block. The line `require("lualine").setup(lualine_config)` (currently line 197)
becomes the only setup call.

**Step B — add K8s context component:**

Insert the following before the FIRST `ins_right({` call (currently line 145 — the `lsp_status`
component):

```lua
      -- ── K8s context (cached) ────────────────────────────────────────
      -- kubectl is called at most once per 10 seconds to avoid blocking redraws.
      -- Returns "" (empty string) when kubectl is unavailable or no context is set;
      -- the cond = function() hides the component entirely in that case.
      local _k8s_ctx_cache = nil
      local _k8s_ctx_time = 0
      local function k8s_context()
        local now = vim.loop.now()
        if _k8s_ctx_cache ~= nil and (now - _k8s_ctx_time) < 10000 then
          return _k8s_ctx_cache
        end
        local handle = io.popen("kubectl config current-context 2>/dev/null")
        if handle then
          local result = handle:read("*l")
          handle:close()
          _k8s_ctx_cache = result or ""
        else
          _k8s_ctx_cache = ""
        end
        _k8s_ctx_time = now
        return _k8s_ctx_cache
      end

      ins_right({
        k8s_context,
        icon = "󱃾",
        cond = function()
          return k8s_context() ~= ""
        end,
        color = ayuline.styles["location"],
      })
```

**PATTERN**: `ui.lua:98-105` — `ins_left`/`ins_right` helper functions already defined there.
**PATTERN**: `ui.lua:145-165` — existing `ins_right()` calls show the component table shape.
**GOTCHA**: `ayuline.styles["location"]` is used by the existing `location` component at
`ui.lua:162-165` — reuse it for visual consistency. Do not invent a new color key.
**GOTCHA**: `_k8s_ctx_cache = nil` initial state is intentional. The `~= nil` check on first call
forces a real kubectl invocation to populate it. After that, the TTL governs refreshes.
**GOTCHA**: `vim.loop.now()` returns milliseconds (not seconds). The TTL is 10000ms = 10s.
**VALIDATE**: `:lua require("lualine").setup` only called once (no duplicate — open `ui.lua` and
count `require("lualine").setup` occurrences — must be exactly 1).
**VALIDATE**: In a terminal with `kubectl` configured → K8s context name appears in statusline.
**VALIDATE**: In a terminal without `kubectl` → statusline shows no K8s component (hidden by cond).

---

## VALIDATION COMMANDS

### Level 1: Neovim starts cleanly

```bash
nvim --headless -c "lua print('ok')" -c "qa"
```
Expected: exits 0, prints "ok", no error messages.

### Level 2: Startup time

```bash
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
```
Expected: final line shows < 100ms total startup time.

### Level 3: Plugin load verification

Inside Neovim:
```
:Lazy
```
Expected: `nvim-lint` and `nvim-autopairs` listed; no red error markers on any plugin.

### Level 4: init.lua line count

```bash
wc -l lua/plugins/editor.lua  # not init.lua — just a sanity check
wc -l init.lua
```
Expected: `init.lua` is ≤ 38 lines (bootstrap + require("config") + lazy.setup only).

### Level 5: Filetype detection

```bash
nvim --headless -c "e .github/workflows/test.yml" -c "lua print(vim.bo.filetype)" -c "qa"
```
Expected: prints `yaml.github-actions`.

### Level 6: which-key groups

Inside Neovim, press `<leader>` and hold — expected: `c` shows "code", `l` shows "lsp".

### Level 7: Format and lint functional

```
:ConformInfo    (in a Go buffer)  → goimports listed as ready
<leader>cf      (in a Lua buffer) → buffer formats, notification shown
<leader>uf                        → "Autoformat disabled" notification
:FormatEnable                     → "Autoformat enabled" notification
```

### Level 8: checkhealth

```
:checkhealth lazy
:checkhealth mason
```
Expected: both green, no errors.

---

## ACCEPTANCE CRITERIA

- [ ] `init.lua` is ≤ 38 lines: only leader setup, lazy bootstrap, `require("config")`, `lazy.setup()`
- [ ] Duplicate FileType autocmd removed from `init.lua` (lives only in `autocmds.lua:64-73`)
- [ ] `treesitter.lua` textobject keymaps: `vaf`, `vif`, `]m`, `[m`, `]]`, `[[` all work
- [ ] `formatting.lua` uses `config = function()`, no duplicate `keys = {}` for `<leader>cf`
- [ ] `FormatDisable`, `FormatDisable!`, `FormatEnable` user commands all work
- [ ] `<leader>uf`, `<leader>cn`, `<leader>cf`, `<leader>cF` keymaps all work
- [ ] `editor.lua` which-key spec includes `<leader>c` (code) and `<leader>l` (lsp) groups
- [ ] `nvim-autopairs` installed and working: `(` → `)` auto-inserted in insert mode
- [ ] `lua/plugins/linting.lua` exists with linters for go/sh/bash/zsh/yaml/yaml.github-actions
- [ ] `golangci_lint` (underscore) used, not `golangci-lint` (hyphen)
- [ ] yamllint diagnostic appears in a YAML file with an error
- [ ] shellcheck diagnostic appears in a shell file with an unquoted variable
- [ ] `.github/workflows/*.yml` → filetype is `yaml.github-actions`
- [ ] `gh_actions_ls` attaches to workflow files (`:LspInfo` shows it)
- [ ] actionlint runs on workflow files and surfaces diagnostics
- [ ] `lualine.setup()` called exactly once in `ui.lua`
- [ ] K8s context component present in statusline when `kubectl` is configured
- [ ] K8s context hidden (not empty string shown) when `kubectl` unavailable
- [ ] Startup time < 100ms
- [ ] `lazy-lock.json` committed after `nvim-lint` and `nvim-autopairs` are installed

---

## COMPLETION CHECKLIST

- [ ] Task 1: `editor.lua` — which-key groups + nvim-autopairs added
- [ ] Task 2: `treesitter.lua` — textobject keymaps moved in
- [ ] Task 3: `formatting.lua` — converted to `config = function()`, commands + keymaps moved in
- [ ] Task 4: `init.lua` — stripped to ≤ 38 lines
- [ ] Task 5: `linting.lua` — created with nvim-lint spec
- [ ] Task 6: `autocmds.lua` — GitHub Actions filetype pattern added
- [ ] Task 7: `ui.lua` — dead lualine.setup() removed, K8s component added
- [ ] All validation commands executed and passing
- [ ] `lazy-lock.json` committed
- [ ] No regressions: existing textobject keymaps, format-on-save, LSP all still work

---

## NOTES

**Why tasks 1–3 before task 4?**
`init.lua` cleanup (task 4) must happen LAST among the refactor tasks. If you delete the
textobject keymaps from `init.lua` before adding them to `treesitter.lua`, there is a window
where the keymaps don't exist. Tasks 1–3 prepare the destinations, task 4 does the cleanup.

**Why `config = function()` for formatting.lua instead of `opts = {}`?**
`vim.api.nvim_create_user_command()` is an imperative call — it cannot live inside an `opts`
table that lazy.nvim passes to `setup()`. We need a `config` function to create the commands
and keymaps. When using `config = function()`, you must call `require("conform").setup()`
yourself — lazy.nvim no longer does it automatically.

**Why is `<leader>cf` duplicated between `init.lua` and `formatting.lua`?**
It was added to `formatting.lua`'s `keys = {}` table at spec creation time (task-based loading
trigger), and independently added to `init.lua` when the format commands were added later. Both
need to be consolidated into the single `config = function()` approach in task 3.

**Why does `yaml.github-actions` need a Lua pattern with `%.github`?**
In Lua patterns (used by `vim.filetype.add`), `.` matches any character unless escaped as `\.`.
The dot in `.github` must be `%.github` to match a literal dot, not any character. Without the
escape, the pattern would match `Xgithub/workflows/` which is incorrect.

**golangci-lint performance:**
golangci-lint can take 5–30s on large Go projects. This is expected and does not block editing
since `try_lint()` is fully async. If it is too noisy or slow for a specific project, temporarily
remove `golangci_lint` from `linters_by_ft` with `:lua require("lint").linters_by_ft.go = {}`.

**K8s context TTL:**
10 seconds is the right balance between freshness and not blocking. `kubectl config current-context`
reads a local file (`~/.kube/config`) and is normally < 5ms, but on some setups (cloud auth
plugins) it can take 100–500ms. The TTL ensures worst-case latency affects at most one redraw
per 10 seconds rather than every redraw.
