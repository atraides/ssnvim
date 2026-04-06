## v0.4.1 (2026-04-06)

### Fix

- **keymaps**: replace deprecated diagnostic navigation with vim.diagnostic.jump()

## v0.4.0 (2026-04-06)

### Feat

- **editor**: add mini.pairs for auto-close bracket pairs
- **flash**: enable jump_labels for f/t/F/T char motions
- **plugins**: add flash, treesj, mini.pairs; enable noice LSP overrides

### Fix

- **review**: resolve 14 pre-release issues across config files

### Refactor

- **plugins**: swap autopairs for mini.surround; fix keymap conflicts

## v0.3.1 (2026-04-05)

### Fix

- **conform**: register keymaps in init hook so they load before plugin events

## v0.3.0 (2026-04-05)

### Feat

- add diffview, nvim-lint, autopairs; refactor configs into plugin files
- **formatting**: add Phase 7 conform.nvim with formatter stack
- **completion**: add Phase 6 completion stack with blink.cmp and Copilot
- **treesitter**: add Phase 4 treesitter, textobjects, and gh-actions grammar
- **lsp**: add Phase 5 LSP stack and enhance snacks dashboard
- **snacks**: add snacks.nvim as navigation and UI hub
- **editor**: add Phase 3 editor plugins and todo-comments
- **ui**: add noice.nvim for enhanced cmdline and notification UI
- bootstrap foundation config and UI layer (phases 1-2)
- Hard reset, to start with a clean slate
- **lsp**: implement Phase 5 — LSP config with native completion and keymaps
- **treesitter**: implement Phase 4 — treesitter with textobjects, folds, and buffer nav
- **phase-3**: add snacks.nvim, noice, which-key, and gitsigns
- **ui**: replace witch-line with lualine.nvim statusline
- add foundation config and UI layer (phases 1-2)
- Recreate with native plugin support and nvim 0.12

### Fix

- **TS**: Add additional languages
- Enable snacks.vim features
- Fix coloring issues with the statusline
- migrate vim.hl API, disable unused providers, remove witch-line lock entry

## v0.2.3 (2026-04-02)

### Fix

- Minor ui tweak and new color palette

## v0.2.2 (2026-04-02)

### Fix

- Fix incorrect todo-comments inclusion

## v0.2.1 (2026-04-02)

### Fix

- Add todo-comments plugin

## v0.2.0 (2026-03-31)

### Feat

- add commit skill for conventional commit workflow

## v0.1.1 (2026-03-31)

### Fix

- Fix sync issue with autocomplete on github workflow files

## v0.1.0 (2026-03-31)

### Feat

- Add yamllint configuration
- **ui**: add noice.nvim for enhanced cmdline/notifications and tweak lsp_status icon
- **ui**: switch to tokyonight theme with custom lualine statusline
- **github-actions**: Phase 9 — yaml.github-actions filetype, gh_actions_ls, actionlint, gh-actions.nvim
- **polish**: Phase 8 — README, keybinding reference, phase complete
- **format-lint**: Phase 7 — conform.nvim format-on-save + nvim-lint async linting
- **completion**: Phase 6 — blink.cmp + Copilot completion engine
- **lsp**: Phase 5 — mason, nvim-lspconfig, schemastore, LSP keymaps
- **treesitter**: Phase 4 — nvim-treesitter highlight, indent, incremental selection
- **nav**: Phase 3 — snacks picker/lazygit/terminal, oil, gitsigns, which-key, autopairs
- **ui**: Phase 2 — rose-pine colorscheme, auto-dark-mode, lualine statusline
- **core**: Phase 1 foundation — options, keymaps, autocmds, lazy bootstrap
- **ai**: Create Product Requirements Document and Global Rules
- **core**: Initial commit with claude commands

### Fix

- **gh**: Add a workflow to release for chezmoi
- Change the light theme to Ayu
- **cz**: Add commitizen configuration
- **lint**: Fix liniting issue where yamllint attached to github workflows
