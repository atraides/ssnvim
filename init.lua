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
