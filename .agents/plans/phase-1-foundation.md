# Feature: Phase 1 — Foundation

The following plan should be complete, but validate all Neovim API calls and patterns before
implementing. Pay special attention to `vim.filetype.add` patterns for Helm detection —
this is a common source of subtle bugs.

## Feature Description

Build the Neovim configuration foundation: sensible editor defaults, non-plugin keymaps,
autocommands for filetype detection and QoL, and a bootstrapped lazy.nvim plugin manager
(no plugin specs yet). Every setting is commented with its purpose. The result is a working,
minimal Neovim that is functional without any plugins.

## User Story

As a developer with 20+ years of Vim experience moving to a from-scratch Neovim config,
I want a solid foundation layer with sensible defaults, clean keymaps, and Helm filetype detection,
so that every subsequent phase builds on a stable, understood base.

## Problem Statement

The repo has no Lua files. Before any plugins can be added, there must be a working entry point,
editor options, non-plugin keymaps, autocommands (especially Helm filetype detection), and the
lazy.nvim bootstrap — all explicitly commented and incrementally testable.

## Solution Statement

Create 5 files in strict dependency order: `.gitignore` → `init.lua` → `lua/config/options.lua`
→ `lua/config/keymaps.lua` → `lua/config/autocmds.lua`. lazy.nvim is bootstrapped in `init.lua`
but no plugin specs are loaded in this phase. The config is valid Lua, passes `luacheck`, and
Neovim opens cleanly with `:checkhealth` showing no config errors.

## Feature Metadata

**Feature Type**: New Capability (greenfield)
**Estimated Complexity**: Low
**Primary Systems Affected**: init.lua, lua/config/
**Dependencies**: Neovim 0.11+, git (for lazy.nvim bootstrap), internet (first-run lazy clone only)

---

## CONTEXT REFERENCES

### Relevant Codebase Files — MUST READ BEFORE IMPLEMENTING

- `CLAUDE.md` (full file) — project conventions, naming rules, keymap patterns, autocmd patterns,
  anti-patterns to avoid, and the module-per-concern architecture
- `.claude/PRD.md` §6 (Architecture & Patterns) — canonical code snippets for init.lua structure,
  filetype detection, and K8s lualine component
- `.claude/PRD.md` §11 (Phase 1 checklist) — exact acceptance criteria for this phase

### New Files to Create

- `.gitignore` — exclude build artifacts; include lazy-lock.json
- `init.lua` — entry point: bootstrap lazy.nvim, require config modules
- `lua/config/options.lua` — all `vim.opt.*` settings
- `lua/config/keymaps.lua` — non-plugin keymaps (no LSP, no plugin keys)
- `lua/config/autocmds.lua` — Helm ftdetect, trailing whitespace trim, highlight-on-yank

### Relevant Documentation — READ BEFORE IMPLEMENTING

- [lazy.nvim installation](https://lazy.folke.io/installation)
  - Section: "Structured Setup" — shows the exact bootstrap snippet and `require("lazy").setup()`
    with a spec path; Why: init.lua bootstrap pattern
- [vim.filetype.add() — Neovim docs](https://neovim.io/doc/user/lua.html#vim.filetype.add())
  - Why: correct API for Helm pattern-based filetype detection (NOT `autocmd BufRead`)
- [lazy.nvim configuration](https://lazy.folke.io/configuration)
  - Section: `spec` field — how to point lazy at `lua/plugins/` directory (needed even though
    plugins/ is empty in Phase 1); Why: sets up the spec path for all future phases
- [Neovim Lua guide — vim.opt](https://neovim.io/doc/user/lua-guide.html#lua-guide-options)
  - Why: documents `vim.opt` vs `vim.o` vs `vim.wo` distinctions; use `vim.opt` exclusively
- [which-key.nvim spec format](https://github.com/folke/which-key.nvim#%EF%B8%8F-mappings)
  - Why: keymaps in keymaps.lua must use the `desc` field so which-key (Phase 3) picks them
    up automatically — no registration step needed

### Patterns to Follow

**Module require pattern (init.lua):**
```lua
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")   -- lazy bootstrap + setup
```

**vim.opt grouping (options.lua):**
```lua
-- ── UI ────────────────────────────────────────────────────────────────
vim.opt.number = true          -- show absolute line number on cursor line
vim.opt.relativenumber = true  -- relative numbers on all other lines
```

**Keymap pattern (keymaps.lua) — always include desc:**
```lua
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
```

**Augroup pattern (autocmds.lua):**
```lua
local group = vim.api.nvim_create_augroup("ssnvim_<name>", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  ...
})
```

**Helm filetype detection — use vim.filetype.add, NOT autocmd:**
```lua
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.tpl"]  = "helm",
    ["helmfile.*%.yaml"]      = "helm",
  },
})
```

**lazy.nvim bootstrap (init.lua):**
```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    lazyrepo, lazypath,
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

require("lazy").setup({
  spec = { { import = "plugins" } },  -- will load lua/plugins/**/*.lua
  defaults = { lazy = true },
  install = { colorscheme = { "default" } },
  checker = { enabled = false },      -- no auto-update checks
})
```

---

## IMPLEMENTATION PLAN

### Phase A: Scaffolding

Create the directory structure and `.gitignore` before writing any Lua.

**Tasks:**
- Create `.gitignore`
- Create `lua/config/` directory (by creating a file inside it)
- Create `lua/plugins/` directory with an empty placeholder (lazy needs it to exist)

### Phase B: Entry Point

`init.lua` must be written before `config/` modules since it defines the require chain.

**Tasks:**
- Set `mapleader` and `maplocalleader` BEFORE lazy bootstrap (required by lazy.nvim docs)
- Bootstrap lazy.nvim with error handling
- Require the three config modules
- Call `require("lazy").setup()` pointing at `lua/plugins/`

### Phase C: Options

Write `lua/config/options.lua` covering all `vim.opt` settings relevant to the user's workflow.

**Tasks:**
- UI group: number, relativenumber, signcolumn, cursorline, colorcolumn, termguicolors, wrap
- Indentation group: expandtab, tabstop, shiftwidth, softtabstop, smartindent
- Search group: ignorecase, smartcase, hlsearch, incsearch
- Files group: undofile, swapfile=false, backup=false, updatetime, timeoutlen
- Splits group: splitbelow, splitright
- Clipboard: `unnamedplus` (system clipboard)
- Scrolloff: 8 / sidescrolloff: 8
- List chars: show trailing spaces and tab indicators

### Phase D: Keymaps

Write `lua/config/keymaps.lua` with non-plugin bindings only.

**Tasks:**
- Clear search highlight: `<Esc>` in normal mode
- Window navigation: `<C-h/j/k/l>` → `<C-w>h/j/k/l`
- Resize windows: `<C-Up/Down/Left/Right>`
- Buffer navigation: `[b` / `]b`
- Move selected lines up/down in visual mode: `J`/`K`
- Keep cursor centered on `<C-d>` / `<C-u>`
- Paste without losing register: `<leader>p` (paste over selection without yanking)
- Delete without yanking: `<leader>d`
- Better indenting in visual mode (stay in visual after `<`/`>`)
- Quickfix navigation: `[q` / `]q`
- Diagnostic navigation: `[d` / `]d`

### Phase E: Autocommands

Write `lua/config/autocmds.lua`.

**Tasks:**
- Helm filetype detection via `vim.filetype.add` (NOT autocmd — see Patterns)
- Trailing whitespace trim on save (exclude markdown)
- Highlight on yank (`TextYankPost`)
- Restore cursor position on file open (`BufReadPost`)
- Auto-resize splits on terminal resize (`VimResized`)
- Set `ft=sh` fallback for zsh files without shebang

---

## STEP-BY-STEP TASKS

### CREATE `.gitignore`

- **IMPLEMENT**: Exclude Neovim runtime artifacts; explicitly INCLUDE lazy-lock.json
- **CONTENT**:
  ```
  # Neovim runtime artifacts
  *.log
  .luarc.json
  *.env

  # OS
  .DS_Store

  # Do NOT ignore lazy-lock.json — commit it for reproducible installs
  ```
- **VALIDATE**: `cat .gitignore` — confirm lazy-lock.json is NOT listed

---

### CREATE `lua/plugins/.gitkeep`

- **IMPLEMENT**: Empty file so git tracks the directory; lazy.nvim's `{ import = "plugins" }`
  requires the directory to exist at startup
- **VALIDATE**: `ls lua/plugins/` → shows `.gitkeep`

---

### CREATE `init.lua`

- **IMPLEMENT**:
  1. Set `vim.g.mapleader = " "` and `vim.g.maplocalleader = "\\"` — MUST be before lazy bootstrap
  2. lazy.nvim bootstrap snippet (see Patterns section above) — uses `vim.uv` (0.10+) with
     `vim.loop` fallback for compatibility
  3. `require("config.options")`
  4. `require("config.keymaps")`
  5. `require("config.autocmds")`
  6. `require("lazy").setup({ spec = { { import = "plugins" } }, ... })`
- **GOTCHA**: Leader must be set before ANY plugin loads — put it at the very top of init.lua,
  before the lazy bootstrap block
- **GOTCHA**: `defaults = { lazy = true }` — all plugins lazy by default; Phase 1 has no plugins
  so this is safe
- **GOTCHA**: `install = { colorscheme = { "default" } }` — prevents error on fresh install
  when rose-pine isn't yet installed
- **VALIDATE**: `nvim --headless -c "lua print('ok')" -c "qa"` — exits 0 with no errors

---

### CREATE `lua/config/options.lua`

- **IMPLEMENT**: Full `vim.opt.*` settings in labeled groups (see Phase C above)
- **PATTERN**: Group with `-- ── LABEL ──...` comment headers for readability
- **SETTINGS** (complete list, comment each line):

  ```lua
  -- ── UI ────────────────────────────────────────────────────────────────
  vim.opt.number = true             -- absolute line number on cursor line
  vim.opt.relativenumber = true     -- relative numbers everywhere else
  vim.opt.signcolumn = "yes"        -- always show sign column (prevents layout shift)
  vim.opt.cursorline = true         -- highlight the line the cursor is on
  vim.opt.colorcolumn = "100"       -- visual ruler at 100 chars
  vim.opt.termguicolors = true      -- 24-bit RGB colours (required for most colorschemes)
  vim.opt.wrap = false              -- no line wrapping
  vim.opt.scrolloff = 8             -- keep 8 lines above/below cursor
  vim.opt.sidescrolloff = 8         -- keep 8 cols left/right of cursor
  vim.opt.showmode = false          -- mode shown in statusline (lualine), not cmdline

  -- ── Indentation ───────────────────────────────────────────────────────
  vim.opt.expandtab = true          -- spaces, not tabs
  vim.opt.tabstop = 2               -- tab = 2 spaces
  vim.opt.shiftwidth = 2            -- indent step = 2 spaces
  vim.opt.softtabstop = 2           -- backspace deletes 2 spaces at once
  vim.opt.smartindent = true        -- auto-indent on new lines

  -- ── Search ────────────────────────────────────────────────────────────
  vim.opt.ignorecase = true         -- case-insensitive search
  vim.opt.smartcase = true          -- case-sensitive if pattern has uppercase
  vim.opt.hlsearch = true           -- highlight all matches (cleared with <Esc>)
  vim.opt.incsearch = true          -- live search preview as you type

  -- ── Files & Undo ──────────────────────────────────────────────────────
  vim.opt.undofile = true           -- persistent undo across sessions
  vim.opt.swapfile = false          -- no swap files
  vim.opt.backup = false            -- no backup files
  vim.opt.updatetime = 250          -- faster CursorHold (used by LSP hover)
  vim.opt.timeoutlen = 300          -- shorter wait for mapped key sequences

  -- ── Splits ────────────────────────────────────────────────────────────
  vim.opt.splitbelow = true         -- horizontal splits open below
  vim.opt.splitright = true         -- vertical splits open to the right

  -- ── Clipboard ─────────────────────────────────────────────────────────
  vim.opt.clipboard = "unnamedplus" -- use system clipboard for all yank/paste

  -- ── Visual indicators ─────────────────────────────────────────────────
  vim.opt.list = true               -- show invisible characters
  vim.opt.listchars = {
    tab = "» ",                     -- tab character
    trail = "·",                    -- trailing space
    nbsp = "␣",                     -- non-breaking space
  }

  -- ── Completion ────────────────────────────────────────────────────────
  vim.opt.completeopt = { "menuone", "noselect" }  -- blink.cmp compatible

  -- ── Folds (treesitter in Phase 4) ─────────────────────────────────────
  vim.opt.foldmethod = "manual"     -- start with no folds; treesitter overrides in Phase 4
  vim.opt.foldenable = false        -- folds open by default
  ```

- **VALIDATE**: `nvim --headless -c ":set number?" -c "qa"` → output includes `number`

---

### CREATE `lua/config/keymaps.lua`

- **IMPLEMENT**: All non-plugin keymaps; every entry has `desc =`
- **PATTERN**: Group by concern with comment headers
- **GOTCHA**: NO LSP keymaps here — those go in an `LspAttach` autocmd in `lua/plugins/lsp.lua`
- **GOTCHA**: NO plugin keymaps here — those go in their plugin spec `keys = {}`
- **CONTENT**:

  ```lua
  -- ── Utility ───────────────────────────────────────────────────────────
  -- Clear search highlight on <Esc> in normal mode
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

  -- ── Window navigation ─────────────────────────────────────────────────
  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

  -- ── Window resize ─────────────────────────────────────────────────────
  vim.keymap.set("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
  vim.keymap.set("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
  vim.keymap.set("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
  vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

  -- ── Buffer navigation ─────────────────────────────────────────────────
  vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
  vim.keymap.set("n", "]b", "<cmd>bnext<cr>",     { desc = "Next buffer" })

  -- ── Scrolling — keep cursor centred ───────────────────────────────────
  vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centred)" })
  vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centred)" })

  -- ── Move lines in visual mode ─────────────────────────────────────────
  vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
  vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

  -- ── Better indenting in visual mode (stay in visual) ─────────────────
  vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
  vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

  -- ── Paste / delete without clobbering register ────────────────────────
  vim.keymap.set("x", "<leader>p", '"_dP',  { desc = "Paste without yanking selection" })
  vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

  -- ── Quickfix navigation ───────────────────────────────────────────────
  vim.keymap.set("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })
  vim.keymap.set("n", "]q", "<cmd>cnext<cr>",     { desc = "Next quickfix item" })

  -- ── Diagnostic navigation (LSP) ───────────────────────────────────────
  -- These work without LSP (e.g., nvim-lint diagnostics); LSP adds more in lsp.lua
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
  ```

- **VALIDATE**: `nvim --headless -c "lua print(vim.inspect(vim.api.nvim_get_keymap('n')))" -c "qa" 2>&1 | grep "Clear search"` → should print the keymap entry

---

### CREATE `lua/config/autocmds.lua`

- **IMPLEMENT**: 5 autocommand groups; Helm detection uses `vim.filetype.add` (not autocmd)
- **GOTCHA**: `vim.filetype.add` must be called at module load time (top-level), NOT inside an
  autocmd callback — it registers patterns with Neovim's filetype detection system directly
- **GOTCHA**: Trailing whitespace trim must exclude `markdown` filetype — trailing spaces are
  significant in Markdown (two trailing spaces = line break)
- **GOTCHA**: Restore cursor uses `'"` mark — requires wrapping in `pcall` to avoid error on
  fresh files with no saved position
- **CONTENT**:

  ```lua
  -- ── Helm filetype detection ───────────────────────────────────────────
  -- Uses vim.filetype.add (not autocmd) — runs before BufRead, more reliable
  vim.filetype.add({
    pattern = {
      [".*/templates/.*%.yaml"] = "helm",
      [".*/templates/.*%.tpl"]  = "helm",
      ["helmfile.*%.yaml"]      = "helm",
    },
  })

  -- ── Highlight on yank ─────────────────────────────────────────────────
  local yank_group = vim.api.nvim_create_augroup("ssnvim_yank", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = yank_group,
    desc = "Highlight yanked text briefly",
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
  })

  -- ── Trailing whitespace trim ──────────────────────────────────────────
  local trim_group = vim.api.nvim_create_augroup("ssnvim_trim", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = trim_group,
    desc = "Remove trailing whitespace on save (except markdown)",
    callback = function()
      if vim.bo.filetype == "markdown" then return end
      local view = vim.fn.winsaveview()
      vim.cmd([[%s/\s\+$//e]])
      vim.fn.winrestview(view)
    end,
  })

  -- ── Restore cursor position ───────────────────────────────────────────
  local cursor_group = vim.api.nvim_create_augroup("ssnvim_cursor", { clear = true })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = cursor_group,
    desc = "Restore cursor to last known position",
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local line_count = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= line_count then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  -- ── Resize splits on terminal resize ─────────────────────────────────
  local resize_group = vim.api.nvim_create_augroup("ssnvim_resize", { clear = true })
  vim.api.nvim_create_autocmd("VimResized", {
    group = resize_group,
    desc = "Equalize split sizes when terminal is resized",
    callback = function() vim.cmd("tabdo wincmd =") end,
  })
  ```

- **VALIDATE**:
  ```bash
  # Test Helm detection
  nvim --headless -c "edit /tmp/test-chart/templates/deploy.yaml" \
    -c "lua print(vim.bo.filetype)" -c "qa" 2>&1
  # Expected output: helm
  ```

---

## TESTING STRATEGY

### Manual Validation (no test framework — Lua config, not application code)

All validation is done by launching Neovim with `--headless` and inspecting state, or by
opening Neovim interactively and verifying behavior.

### Edge Cases to Verify

- `helmfile.yaml` → `ft=helm` (not `yaml`)
- `templates/deployment.yaml` inside a Helm chart → `ft=helm`
- A `templates/deployment.yaml` that is NOT inside a Helm chart (just a directory called
  `templates`) → this WILL match `ft=helm` too; this is acceptable and matches `helm-ls` behavior
- Markdown file saved with trailing spaces → spaces preserved (trim excluded)
- Normal file saved with trailing spaces → spaces removed, cursor position unchanged
- File opened for the first time → cursor at line 1 (no error from restore-cursor autocmd)
- File opened after being previously edited → cursor restores to last position

---

## VALIDATION COMMANDS

### Level 1: Neovim launches cleanly

```bash
nvim --headless -c "qa" 2>&1
# Expected: no output (exit 0)
```

### Level 2: Options are set

```bash
nvim --headless -c "lua assert(vim.opt.number:get() == true, 'number not set')" \
  -c "lua assert(vim.opt.expandtab:get() == true, 'expandtab not set')" \
  -c "lua assert(vim.opt.scrolloff:get() == 8, 'scrolloff not 8')" \
  -c "lua print('options OK')" -c "qa" 2>&1
# Expected: options OK
```

### Level 3: Helm filetype detection

```bash
mkdir -p /tmp/ssnvim-test/templates
touch /tmp/ssnvim-test/templates/deploy.yaml
nvim --headless -c "edit /tmp/ssnvim-test/templates/deploy.yaml" \
  -c "lua assert(vim.bo.filetype == 'helm', 'expected helm, got: ' .. vim.bo.filetype)" \
  -c "lua print('helm detection OK')" -c "qa" 2>&1
# Expected: helm detection OK
```

### Level 4: Leader key set before lazy

```bash
nvim --headless \
  -c "lua assert(vim.g.mapleader == ' ', 'mapleader not space')" \
  -c "lua print('leader OK')" -c "qa" 2>&1
# Expected: leader OK
```

### Level 5: Startup time

```bash
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
# Expected: total time < 100ms
```

### Level 6: Interactive smoke test

Open Neovim normally and verify:
- `nvim` opens with no error messages
- Line numbers are visible (absolute + relative)
- `:set number?` → `number`
- `:lua print(vim.g.mapleader)` → ` ` (space)
- `:Lazy` opens the lazy.nvim UI with no errors (no plugins installed = empty list is OK)
- Create a file, yank a line → text briefly highlights
- Add trailing spaces, save → spaces removed
- Open `templates/deploy.yaml` → statusline or `:set ft?` shows `helm`

---

## ACCEPTANCE CRITERIA

- [ ] `nvim` opens cleanly with no error messages or stacktraces
- [ ] `nvim --headless -c "qa"` exits 0 with no output
- [ ] `vim.g.mapleader` is `" "` (space)
- [ ] `vim.opt.number:get()` is `true`
- [ ] `vim.opt.expandtab:get()` is `true`
- [ ] `vim.opt.clipboard:get()` contains `"unnamedplus"`
- [ ] File at `*/templates/*.yaml` detects as `ft=helm`
- [ ] `helmfile*.yaml` detects as `ft=helm`
- [ ] `<C-h/j/k/l>` navigate between windows
- [ ] `<Esc>` in normal mode clears search highlight
- [ ] Trailing whitespace trimmed on BufWritePre (non-markdown files)
- [ ] Yank briefly highlights the yanked region
- [ ] Cursor restores to last position on file re-open (no error on fresh file)
- [ ] `:Lazy` opens without errors (empty plugin list is fine)
- [ ] Startup time < 100ms (`--startuptime`)
- [ ] All 5 files committed to git: `.gitignore`, `init.lua`, `lua/config/options.lua`,
      `lua/config/keymaps.lua`, `lua/config/autocmds.lua`

---

## COMPLETION CHECKLIST

- [ ] `.gitignore` created and does NOT exclude `lazy-lock.json`
- [ ] `lua/plugins/.gitkeep` created (lazy needs the directory)
- [ ] `init.lua` created with leader set BEFORE lazy bootstrap
- [ ] `lua/config/options.lua` created with all settings commented
- [ ] `lua/config/keymaps.lua` created with all keymaps having `desc =`
- [ ] `lua/config/autocmds.lua` created with Helm using `vim.filetype.add`
- [ ] All Level 1-5 validation commands pass
- [ ] Interactive smoke test passes
- [ ] All acceptance criteria checked off

---

## NOTES

**Why `vim.filetype.add` instead of `BufRead` autocmd for Helm detection:**
`vim.filetype.add` with `pattern` runs during Neovim's filetype detection pipeline, before
`BufRead` autocmds fire. This means `vim.bo.filetype` is set correctly before any LSP or plugin
sees the buffer — critical for preventing `yamlls` from attaching to Helm buffers in Phase 5.
Using a `BufRead` autocmd instead would set `ft` after some plugins have already reacted.

**Why `lua/plugins/.gitkeep`:**
`require("lazy").setup({ spec = { { import = "plugins" } } })` in init.lua tells lazy to look
for specs in `lua/plugins/`. If the directory doesn't exist, Neovim logs a warning on startup.
The `.gitkeep` ensures the directory exists without adding any plugin specs yet.

**Why `defaults = { lazy = true }` in lazy setup:**
All future plugins default to lazy-loading. Each plugin spec opts in to eager loading with
`lazy = false` when needed (e.g., `oil.nvim`, `rose-pine`). This keeps startup time minimal
as the plugin count grows through Phases 2-7.

**K8s context lualine caching (Phase 2 concern, noted here):**
The `io.popen("kubectl config current-context")` call for the lualine statusline component MUST
cache its result. Do NOT call `io.popen` on every statusline redraw — it blocks the UI. Cache
in a module-level variable, invalidate on `BufEnter` or `FocusGained`. This is a Phase 2 task
but worth noting during foundation so the pattern is front-of-mind.
