# Feature: Phase 2 — UI (Colorscheme, Auto-Dark-Mode, Statusline)

The following plan should be complete, but validate all lazy.nvim spec patterns and plugin
API calls against the codebase before implementing. Pay special attention to the K8s context
caching strategy — io.popen must NOT be called on every statusline redraw.

## Feature Description

Add the visual layer to ssnvim: the Rosé Pine colorscheme (with automatic macOS dark/light mode
switching), and a lualine statusline that includes a cached Kubernetes context component. This
phase produces a single file: `lua/plugins/ui.lua`. The stub `lua/plugins/init.lua` is removed
once `ui.lua` exists, since lazy.nvim loads all `*.lua` files under `lua/plugins/`.

## User Story

As a developer who works in both light and dark environments across multiple Kubernetes clusters,
I want my colorscheme to automatically follow macOS appearance and my current kubectl context
visible in the statusline, so that I never manually toggle the theme and always know which
cluster I'm targeting.

## Problem Statement

Phase 1 left Neovim with no colorscheme and no statusline. The editor runs but is visually
unpolished — default colours, no git branch, no filetype indicator, no K8s context awareness.
Additionally, manual colorscheme switching every time macOS appearance changes is friction that
breaks flow.

## Solution Statement

Create `lua/plugins/ui.lua` with three lazy.nvim plugin specs:
1. `rose-pine/neovim` — loaded eagerly as the colorscheme
2. `f-person/auto-dark-mode.nvim` — polls macOS and calls rose-pine variant switches
3. `nvim-lualine/lualine.nvim` — statusline with a cached kubectl context custom component

Remove `lua/plugins/init.lua` (the Phase 1 stub) since lazy.nvim will now find real specs.

## Feature Metadata

**Feature Type**: New Capability
**Estimated Complexity**: Low
**Primary Systems Affected**: `lua/plugins/ui.lua` (new), `lua/plugins/init.lua` (deleted)
**Dependencies**: rose-pine/neovim, f-person/auto-dark-mode.nvim, nvim-lualine/lualine.nvim

---

## CONTEXT REFERENCES

### Relevant Codebase Files — READ BEFORE IMPLEMENTING

- `init.lua` (lines 32–37) — lazy.nvim setup call; `spec = { { import = "plugins" } }` loads
  all `*.lua` files under `lua/plugins/`. Removing `init.lua` stub + adding `ui.lua` is sufficient.
- `lua/plugins/init.lua` — Phase 1 stub returning `{}`. DELETE this file in Task 1.
- `lua/config/options.lua` (line 9) — `vim.opt.termguicolors = true` is already set; required for
  rose-pine to render correctly. No change needed.
- `lua/config/autocmds.lua` (lines 1–14) — Helm filetype detection via `vim.filetype.add`.
  Confirms pattern: no BufRead autocmds, `vim.filetype.add` preferred. lualine filetype component
  will correctly display `helm` for Helm buffers.
- `.claude/PRD.md` (lines 221–243) — Canonical reference implementations for both the K8s context
  component and the auto-dark-mode setup. Use these as the source of truth.

### New Files to Create

- `lua/plugins/ui.lua` — Three lazy.nvim specs: rose-pine, auto-dark-mode, lualine

### Files to Delete

- `lua/plugins/init.lua` — Phase 1 stub, no longer needed once `ui.lua` exists

### Relevant Documentation — READ BEFORE IMPLEMENTING

- [rose-pine/neovim README](https://github.com/rose-pine/neovim#readme)
  - Sections: Installation, Usage (`vim.cmd("colorscheme rose-pine")`, variant names)
  - Why: Confirms correct colorscheme names (`rose-pine`, `rose-pine-moon`, `rose-pine-dawn`)
- [f-person/auto-dark-mode.nvim README](https://github.com/f-person/auto-dark-mode.nvim#readme)
  - Sections: Setup, `set_dark_mode` / `set_light_mode` callbacks, `update_interval`
  - Why: Confirms callback API and macOS detection mechanism
- [lualine.nvim README — custom components](https://github.com/nvim-lualine/lualine.nvim#custom-components)
  - Sections: Custom function components, sections structure
  - Why: Confirms how to inject a Lua function as a statusline section component
- [lualine.nvim README — themes](https://github.com/nvim-lualine/lualine.nvim#themes)
  - Why: Confirms `theme = "rose-pine"` is a valid lualine theme name

### Patterns to Follow

**lazy.nvim eager loading (mirrors future `editor.lua` oil.nvim pattern):**
```lua
{
  "author/plugin.nvim",
  lazy  = false,        -- load at startup, not on demand
  priority = 1000,      -- load before other start plugins (colorscheme only)
  opts  = { ... },
}
```

**lazy.nvim opts vs config:**
- Use `opts = {}` when plugin has a `setup()` that accepts a plain table
- Use `config = function() end` when setup requires logic (conditionals, closures, caching)
- auto-dark-mode and lualine both need `config` due to the K8s caching closure

**K8s context caching pattern (from PRD.md lines 221–229):**
```lua
-- Cache at module load time, not inside the component function
local _k8s_ctx = nil
local function k8s_context()
  if _k8s_ctx == nil then
    local handle = io.popen("kubectl config current-context 2>/dev/null")
    if not handle then
      _k8s_ctx = ""
    else
      _k8s_ctx = handle:read("*a"):gsub("\n", "")
      handle:close()
    end
  end
  return _k8s_ctx ~= "" and ("⎈ " .. _k8s_ctx) or ""
end
```

**IMPORTANT — caching caveat:** The cached value is stale if the user switches kubectl context
mid-session. Accept this tradeoff for MVP. Do NOT call `io.popen` inside the component function
body (called on every statusline redraw ~every 100ms).

**auto-dark-mode setup pattern (from PRD.md lines 232–243):**
```lua
require("auto-dark-mode").setup({
  update_interval = 1000,
  set_dark_mode  = function() vim.cmd("colorscheme rose-pine-moon") end,
  set_light_mode = function() vim.cmd("colorscheme rose-pine-dawn") end,
})
```

**Naming conventions:**
- File: `lua/plugins/ui.lua` (snake_case, function-area named — matches existing pattern)
- Local variables: `snake_case` — `_k8s_ctx` (underscore prefix = module-level cache, not a global)
- No global variables; all locals scoped to the `config` function or module

---

## IMPLEMENTATION PLAN

### Phase 1: Remove Stub

Delete `lua/plugins/init.lua` — the Phase 1 empty-spec stub that was only needed to silence
lazy.nvim's "No specs found" warning. Once `ui.lua` exists, this file must not coexist because
lazy.nvim will load both and the duplicate empty return is harmless but confusing.

### Phase 2: Create `lua/plugins/ui.lua`

Write the three-spec file in this order within the return table:
1. `rose-pine/neovim` — eager, priority 1000, minimal opts (no custom palette overrides for MVP)
2. `f-person/auto-dark-mode.nvim` — eager (must fire at startup), config function with callbacks
3. `nvim-lualine/lualine.nvim` — eager, config function containing K8s cache + lualine setup

### Phase 3: Validate

Launch Neovim and verify visual output, dark/light switching, and statusline correctness.

---

## STEP-BY-STEP TASKS

### TASK 1 — DELETE `lua/plugins/init.lua`

- **ACTION**: Delete the file `lua/plugins/init.lua`
- **REASON**: Phase 1 stub, no longer needed; lazy.nvim will load `ui.lua` instead
- **GOTCHA**: Do not leave the file in place — two files both matching `lua/plugins/*.lua` is fine
  (lazy.nvim merges all specs) but the stub adds confusion and the comment says "Remove this file
  once the first real plugin spec is added in Phase 2"
- **VALIDATE**: `ls lua/plugins/` should show only `ui.lua` after Task 2

---

### TASK 2 — CREATE `lua/plugins/ui.lua`

- **IMPLEMENT**: Write the full three-spec lazy.nvim spec file

**Complete file content:**

```lua
-- lua/plugins/ui.lua — colorscheme, OS-aware dark/light switching, statusline

-- ── Kubernetes context (cached) ───────────────────────────────────────────
-- Cached at module load; avoids calling io.popen on every statusline redraw.
-- Tradeoff: stale if kubectl context changes mid-session (acceptable for MVP).
local _k8s_ctx = nil
local function k8s_context()
  if _k8s_ctx == nil then
    local handle = io.popen("kubectl config current-context 2>/dev/null")
    if not handle then
      _k8s_ctx = ""
    else
      _k8s_ctx = handle:read("*a"):gsub("\n", "")
      handle:close()
    end
  end
  return _k8s_ctx ~= "" and ("⎈ " .. _k8s_ctx) or ""
end

return {

  -- ── Colorscheme: Rosé Pine ──────────────────────────────────────────────
  -- loaded eagerly (lazy=false) and at highest priority so it is applied
  -- before any other plugin can render with the wrong colours.
  -- auto-dark-mode.nvim handles variant switching (moon↔dawn) at runtime.
  {
    "rose-pine/neovim",
    name     = "rose-pine",   -- alias required; repo slug contains slash
    lazy     = false,
    priority = 1000,
    opts     = {},             -- use rose-pine defaults; no palette overrides for MVP
    config   = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd("colorscheme rose-pine") -- initial load; auto-dark-mode overrides immediately
    end,
  },

  -- ── Auto dark/light mode (macOS appearance sync) ────────────────────────
  -- Polls `defaults read -g AppleInterfaceStyle` every update_interval ms.
  -- Switches between rose-pine-moon (dark) and rose-pine-dawn (light).
  {
    "f-person/auto-dark-mode.nvim",
    lazy   = false,
    config = function()
      require("auto-dark-mode").setup({
        update_interval = 1000,                                    -- poll every 1 s
        set_dark_mode   = function() vim.cmd("colorscheme rose-pine-moon")  end,
        set_light_mode  = function() vim.cmd("colorscheme rose-pine-dawn")  end,
      })
    end,
  },

  -- ── Statusline: lualine ─────────────────────────────────────────────────
  -- theme = "rose-pine" auto-matches the active colorscheme.
  -- Right section includes the cached K8s context component.
  {
    "nvim-lualine/lualine.nvim",
    lazy   = false,
    config = function()
      require("lualine").setup({
        options = {
          theme                = "rose-pine",
          globalstatus         = true,   -- single statusline for all windows
          section_separators   = "",     -- no powerline arrows — clean minimal look
          component_separators = "│",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },  -- path=1 → relative path
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location", k8s_context },
        },
      })
    end,
  },

}
```

- **PATTERN**: `lazy = false` + `priority = 1000` mirrors standard colorscheme loading convention
- **PATTERN**: Module-level `_k8s_ctx` cache — prevents `io.popen` on every redraw
- **GOTCHA**: `name = "rose-pine"` is required in the lazy spec because the GitHub repo is
  `rose-pine/neovim` — lazy.nvim uses the name for the `require()` call; without `name`, it
  would try `require("neovim")` which fails
- **GOTCHA**: `auto-dark-mode.nvim` must be `lazy = false` — if lazy-loaded it won't poll at
  startup and the initial variant may be wrong
- **GOTCHA**: Do NOT call `vim.cmd("colorscheme rose-pine")` inside `auto-dark-mode` callbacks
  if `rose-pine` setup hasn't run yet; the load order (rose-pine first in the return table)
  combined with `priority = 1000` ensures rose-pine is always configured before auto-dark-mode
  fires
- **VALIDATE**: `nvim --headless -c "lua require('lazy').load({plugins='rose-pine'})" -c "qa"` exits 0

---

## TESTING STRATEGY

No automated test framework exists for a Neovim Lua config. All validation is manual + headless.

### Manual Validation Checklist

1. **Colorscheme loads** — no "colorscheme not found" error on startup
2. **Dark mode** — set macOS to Dark; Neovim shows rose-pine-moon within ~1 second
3. **Light mode** — set macOS to Light; Neovim shows rose-pine-dawn within ~1 second
4. **Statusline visible** — lualine renders across the bottom with mode, branch, filename, filetype
5. **K8s context** — `⎈ <context-name>` appears in the right section of the statusline
6. **No errors** — `:checkhealth lazy` reports no plugin errors
7. **Startup time** — still < 100ms (adding 3 UI plugins should not materially affect this)

---

## VALIDATION COMMANDS

### Level 1: File Existence

```bash
# Confirm stub is gone and ui.lua exists
ls lua/plugins/
# Expected: ui.lua (only)
```

### Level 2: Lua Syntax Check

```bash
# Check for syntax errors without launching Neovim
luac -p lua/plugins/ui.lua
# Expected: no output (silent = success)
# Note: luac is available if lua is installed; skip if not present
```

### Level 3: Headless Launch (no errors)

```bash
# Launch headless, load plugins, quit — exit 0 = no fatal errors
nvim --headless -c "lua require('lazy').sync()" -c "qa!" 2>&1 | head -20
```

### Level 4: Startup Time

```bash
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
# Goal: total time < 100ms
```

### Level 5: Checkhealth

```bash
# Interactive — run inside Neovim
nvim -c "checkhealth lazy"
# Expected: no ERROR lines
```

### Level 6: Manual Dark/Light Toggle

1. Open Neovim
2. System Settings → Appearance → Dark → Neovim switches to rose-pine-moon within 1–2s
3. System Settings → Appearance → Light → Neovim switches to rose-pine-dawn within 1–2s

---

## ACCEPTANCE CRITERIA

- [ ] `lua/plugins/init.lua` (stub) no longer exists
- [ ] `lua/plugins/ui.lua` exists and returns a valid lazy.nvim spec table (3 specs)
- [ ] Neovim starts with Rosé Pine colorscheme (no default color fallback)
- [ ] Colorscheme auto-switches with macOS Appearance within 1–2 seconds
- [ ] lualine statusline is visible with mode, branch, filename, filetype, location
- [ ] K8s context appears in statusline as `⎈ <context-name>` (or empty if kubectl unavailable)
- [ ] `io.popen` is NOT called on every statusline redraw (cache verified by reading code)
- [ ] `:checkhealth lazy` reports no ERRORs
- [ ] Startup time remains < 100ms

---

## COMPLETION CHECKLIST

- [ ] Task 1: `lua/plugins/init.lua` deleted
- [ ] Task 2: `lua/plugins/ui.lua` created with all three specs
- [ ] Lua syntax verified (luac or headless nvim)
- [ ] Manual dark/light mode switching confirmed
- [ ] Statusline renders correctly with K8s context
- [ ] Startup time verified < 100ms
- [ ] `lazy-lock.json` updated after `:Lazy sync` (commit separately)
- [ ] All acceptance criteria checked off

---

## NOTES

**Plugin load order:** lazy.nvim processes specs in the order they appear in the return table
when `lazy = false`. rose-pine must come before auto-dark-mode so `setup()` runs first. The
`priority = 1000` on rose-pine provides an additional guard.

**`name = "rose-pine"` in the spec:** Without this alias, lazy.nvim derives the module name from
the repo path (`neovim`) which collides with Neovim's own runtime. This is the single most
common mistake when adding this colorscheme.

**K8s context staleness:** The cache is populated once at module load. If the user runs
`kubectl config use-context` mid-session, the statusline will not update until Neovim restarts.
This is an acceptable MVP tradeoff documented in the PRD. A future enhancement could add a
`:KubeRefresh` command that clears `_k8s_ctx = nil`.

**`lazy-lock.json`:** After running `:Lazy sync` to install these three plugins, commit
`lazy-lock.json` as part of the Phase 2 commit. This pins exact versions for reproducibility.

**Confidence score:** 9/10 — All three plugins have stable, simple APIs. The only risk is the
`name = "rose-pine"` gotcha in the lazy spec, which is explicitly called out in Task 2.
