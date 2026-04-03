-- ssnvim — entry point
-- Leader must be set BEFORE lazy.nvim bootstraps so plugin keymaps inherit it.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ── Load config modules ───────────────────────────────────────────────────
require("config")
require("plugins")
