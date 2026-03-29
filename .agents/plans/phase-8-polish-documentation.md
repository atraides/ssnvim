# Feature: Phase 8 — Polish & Documentation

The following plan should be complete, but validate codebase patterns before implementing.
Pay special attention to the keybinding tables — derive them directly from source files, not from memory.

## Feature Description

Phase 8 closes out the ssnvim MVP. All 7 functional build phases are complete and working.
This phase produces the documentation and validation artifacts that make the repo
"push-button installable" on a fresh machine: a complete README, verified health checks,
measured startup time, and a committed lockfile.

No new plugins. No config changes. This is purely documentation + validation.

## User Story

As a developer cloning ssnvim on a new machine,
I want a single `git clone` + `nvim` to produce a fully working editor with no manual steps,
So that I never need to consult external docs or guess what to run.

## Problem Statement

The repo has no README.md. A fresh clone gives no guidance on prerequisites, first-launch
steps (Copilot auth), or what keybindings exist. Phase 8 fixes that.

## Solution Statement

1. Write README.md covering prerequisites, installation, first-launch, and all keybindings.
2. Audit which-key group labels for completeness.
3. Update CLAUDE.md phase status table to mark Phase 8 complete.
4. Provide validation commands for the user to run manually inside Neovim.
5. Commit everything with the Phase 8 commit message.

## Feature Metadata

**Feature Type**: Documentation / Polish
**Estimated Complexity**: Low
**Primary Systems Affected**: `README.md`, `CLAUDE.md`
**Dependencies**: None (reads existing source files only)

---

## CONTEXT REFERENCES

### Relevant Codebase Files — READ THESE BEFORE IMPLEMENTING

- `init.lua` — entry point, lazy bootstrap pattern, establishes leader key
- `lua/config/keymaps.lua` — ALL non-plugin keymaps with desc strings
- `lua/plugins/snacks.lua` (lines 17–30) — `<leader>f*`, `<leader>gg`, `<leader>tt` keys
- `lua/plugins/editor.lua` (lines 13–16, 43–73, 89–96) — `-` oil key, gitsigns `<leader>g*`/`]h`/`[h`, which-key group spec
- `lua/plugins/lsp.lua` (lines 88–108) — LspAttach keymaps: `gd/gD/gI/K/gr/<leader>l*`
- `lua/plugins/completion.lua` (lines 43–49) — completion keymap preset + overrides
- `lua/plugins/formatting.lua` (lines 13–19) — `<leader>cf` key
- `lua/plugins/treesitter.lua` (lines 54–62) — `<A-o>`/`<A-i>` incremental selection keys
- `lua/plugins/ui.lua` — lualine sections, K8s context component
- `lua/config/autocmds.lua` — Helm filetype detection patterns
- `CLAUDE.md` (Build Phases table, lines ~120–140) — needs Phase 8 status updated to ✅

### New Files to Create

- `README.md` (project root) — main documentation file

### Files to Update

- `CLAUDE.md` — change Phase 8 row from `🔲 Not started` to `✅ Complete`

---

## COMPLETE KEYBINDING REFERENCE

Derived from source files. Use this as the source of truth for README tables.

### General (always available)

| Key | Mode | Description |
|-----|------|-------------|
| `<Esc>` | n | Clear search highlight |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | n | Move to left/lower/upper/right window |
| `<C-Up>` / `<C-Down>` | n | Increase / decrease window height |
| `<C-Left>` / `<C-Right>` | n | Decrease / increase window width |
| `[b` / `]b` | n | Previous / next buffer |
| `<C-d>` / `<C-u>` | n | Scroll down / up (cursor stays centred) |
| `[q` / `]q` | n | Previous / next quickfix item |
| `[d` / `]d` | n | Previous / next diagnostic |
| `<leader>e` | n | Show diagnostic float |
| `<leader>d` | n, v | Delete without yanking |
| `J` / `K` | v | Move selection down / up |
| `<` / `>` | v | Indent left / right (stay in visual) |
| `<leader>p` | x | Paste over selection without yanking it |

### File Navigation

| Key | Mode | Description |
|-----|------|-------------|
| `-` | n | Open parent directory (oil.nvim) |

### Find / Picker (`<leader>f`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Find buffers |
| `<leader>fh` | n | Find help |
| `<leader>fs` | n | Find LSP symbols |
| `<leader>fd` | n | Find diagnostics |

### Git (`<leader>g`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>gg` | n | Open lazygit (floating window) |
| `]h` / `[h` | n | Next / prev hunk |
| `<leader>gs` | n, v | Stage hunk (visual: stage selection only) |
| `<leader>gr` | n, v | Reset hunk (visual: reset selection only) |
| `<leader>gp` | n | Preview hunk inline |
| `<leader>gb` | n | Toggle current-line git blame |

### LSP (`<leader>l` — active when LSP is attached)

| Key | Mode | Description |
|-----|------|-------------|
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gI` | n | Go to implementation |
| `K` | n | Hover documentation |
| `gr` | n | Find references |
| `<leader>lr` | n | Rename symbol |
| `<leader>la` | n | Code action |
| `<leader>lf` | n | Format buffer via LSP |

### Code / Format (`<leader>c`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>cf` | n | Format buffer (conform.nvim) |

### Terminal (`<leader>t`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>tt` | n | Open floating terminal |

### Completion (insert mode)

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Navigate items down / up |
| `<Tab>` / `<S-Tab>` | Navigate items / jump snippet placeholders |
| `<CR>` | Accept selected item |
| `<C-e>` | Dismiss completion menu |
| `<C-Space>` | Force-trigger completion |

### Treesitter

| Key | Mode | Description |
|-----|------|-------------|
| `<A-o>` | n, v | Start / expand node selection |
| `<A-i>` | v | Shrink node selection |

---

## IMPLEMENTATION PLAN

### Phase 1: Write README.md

Single new file at the project root. Structure:

```
# ssnvim
Short tagline

## Prerequisites
## Installation
## First Launch
## Keybinding Reference
## Language Support
## Plugin List
```

**Content requirements:**

**Prerequisites section** must list:
- Neovim 0.11+ (not 0.10 — native `vim.lsp.config()` requires 0.11)
- A [Nerd Font](https://www.nerdfonts.com/) (icons in lualine + dashboard)
- `git` (lazy.nvim bootstrap clones via git)
- `lazygit` (for `<leader>gg`)
- `kubectl` (for K8s context in statusline — gracefully absent = no context shown)
- Optional: `pyenv`, `poetry`, or `uv` for Python venv auto-detection

**Installation section** must show:
```bash
git clone https://github.com/<user>/ssnvim ~/.config/nvim
nvim
```
Note that on first launch: lazy.nvim bootstraps itself → installs all 19 plugins →
Mason installs all 13 language servers and tools. This takes ~2–5 minutes.

**First Launch section** must cover:
- `:Copilot auth` — required once to authenticate GitHub Copilot (enterprise OAuth)
- `:checkhealth lazy` and `:Mason` for verifying the install

**Keybinding Reference** — use the tables from the COMPLETE KEYBINDING REFERENCE section above.

**Language Support** — a table mapping filetypes to their LSP + formatter + linter.

**Plugin List** — brief table of the 19 plugins and their purpose (can derive from CLAUDE.md tech stack table).

### Phase 2: Audit which-key Groups

Read `lua/plugins/editor.lua` lines 89–96. Current groups registered:
- `<leader>f` → "find"
- `<leader>g` → "git"
- `<leader>t` → "terminal"
- `<leader>l` → "lsp"
- `<leader>c` → "code"

Verify: every `<leader>*` key defined across all plugin files falls under one of these groups
or is a standalone single-key binding (those don't need groups).
Standalone single-key `<leader>` bindings that are fine without a group:
- `<leader>e` — show diagnostic float
- `<leader>d` — delete without yanking
- `<leader>p` — paste without yanking

No changes needed if the above is confirmed.

### Phase 3: Update CLAUDE.md Phase Table

In `CLAUDE.md`, find the Build Phases table and change:

```
| 8 — Polish | README, checkhealth, startup time, lockfile commit | 🔲 Not started |
```

to:

```
| 8 — Polish | README, checkhealth, startup time, lockfile commit | ✅ Complete |
```

### Phase 4: User-Side Validation (document in README, user runs manually)

These cannot be run by the implementation agent — they require a live Neovim instance.
Document them in the README and/or run them yourself:

```bash
# Startup time (goal: < 100ms)
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log

# Inside Neovim:
# :checkhealth lazy       → no errors
# :checkhealth mason      → all tools installed
# :Mason                  → all servers green
# :Lazy                   → no plugin errors
# :Copilot status         → authenticated
```

### Phase 5: Final Commit

Commit files: `README.md`, `CLAUDE.md`, `lazy-lock.json` (if modified).

Commit message:
```
feat(polish): Phase 8 — README, keybinding reference, phase complete
```

---

## STEP-BY-STEP TASKS

### CREATE `README.md`

- **IMPLEMENT**: Write complete README with all sections listed in Phase 1
- **PATTERN**: Follow ssnvim's clean, minimal aesthetic — no excessive badges or decoration
- **IMPORTS**: None — pure markdown
- **GOTCHA**: Do NOT add Copilot API keys, tokens, or credentials anywhere in the README
- **GOTCHA**: Prerequisites must mention Neovim 0.11+, not just "Neovim" — the native `vim.lsp.config()` API is 0.11-only
- **GOTCHA**: Installation path `~/.config/nvim` — if the user already has a config there, they need to back it up first. Add a note.
- **VALIDATE**: `ls /Users/atraides/Develop/ssnvim/README.md` confirms file exists

### AUDIT `lua/plugins/editor.lua` which-key groups

- **IMPLEMENT**: Read lines 89–96 and confirm all five groups (`find`, `git`, `terminal`, `lsp`, `code`) are present
- **PATTERN**: `editor.lua:89` — which-key v3 spec format `{ "<leader>x", group = "name" }`
- **GOTCHA**: Do NOT use the v2 `require("which-key").register()` API — this project uses v3 spec format
- **VALIDATE**: Confirm no `<leader>` group is missing by cross-referencing the COMPLETE KEYBINDING REFERENCE above

### UPDATE `CLAUDE.md` Phase 8 status

- **IMPLEMENT**: Change `🔲 Not started` → `✅ Complete` for the Phase 8 row
- **PATTERN**: Other completed phases use `✅ Complete` in the same table
- **VALIDATE**: `grep "Phase 8" /path/to/CLAUDE.md` shows `✅ Complete`

---

## VALIDATION COMMANDS

### Level 1: File Existence

```bash
ls /Users/atraides/Develop/ssnvim/README.md
ls /Users/atraides/Develop/ssnvim/lazy-lock.json
```

### Level 2: Content Checks

```bash
# README has all required sections
grep -E "^## (Prerequisites|Installation|First Launch|Keybinding)" /Users/atraides/Develop/ssnvim/README.md

# CLAUDE.md Phase 8 is marked complete
grep "Phase 8" /Users/atraides/Develop/ssnvim/CLAUDE.md
```

### Level 3: Neovim Validation (run manually inside Neovim)

```
:checkhealth lazy
:checkhealth mason
:Mason
:Lazy
nvim --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log
```

### Level 4: Git Status

```bash
git -C /Users/atraides/Develop/ssnvim status
git -C /Users/atraides/Develop/ssnvim log --oneline -3
```

---

## ACCEPTANCE CRITERIA

- [ ] `README.md` exists at project root with Prerequisites, Installation, First Launch, and Keybinding Reference sections
- [ ] All 19 plugins listed in README
- [ ] All keybindings from the COMPLETE KEYBINDING REFERENCE section are in the README
- [ ] `CLAUDE.md` Phase 8 row shows `✅ Complete`
- [ ] `lazy-lock.json` is committed (already in repo — verify it's current)
- [ ] No new plugins added, no config changes made
- [ ] Startup time < 100ms (user validates manually)
- [ ] `:checkhealth lazy` passes (user validates manually)

---

## COMPLETION CHECKLIST

- [ ] `README.md` created with all required sections
- [ ] which-key groups audited — all `<leader>*` prefixes covered
- [ ] `CLAUDE.md` Phase 8 status updated
- [ ] Validation commands listed above executed
- [ ] Final commit created: `feat(polish): Phase 8 — README, keybinding reference, phase complete`

---

## NOTES

**Startup time risk**: If startup is > 100ms, the most likely culprit is a `lazy = false` plugin
that could be deferred. Current `lazy = false` plugins: `rose-pine`, `auto-dark-mode`, `lualine`,
`snacks.nvim`, `blink.cmp`, `oil.nvim`, `mason.nvim`. Of these, only `mason.nvim` is a candidate
for deferral (to `VeryLazy`) — but this is out of scope for Phase 8 unless startup check fails badly.

**lazy-lock.json**: Already committed in the repo from Phase 7. Only needs a new commit if
`:Lazy sync` was run between Phase 7 and now. Check `git status` before committing.

**README GitHub username**: The repo URL in the README should be a placeholder like
`<your-github-username>` — do not hardcode a specific username unless the user confirms it.

**Confidence Score: 9/10** — All content is derived from existing source files. No external
APIs, no new plugins, no architectural decisions. The only risk is a keybinding being missed;
the COMPLETE KEYBINDING REFERENCE section above was built by reading every plugin file.
