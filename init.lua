-- ssnvim — entry point
-- Leader must be set BEFORE lazy.nvim bootstraps so plugin keymaps inherit it.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.env.PROF then
	-- example for lazy.nvim
	-- change this to the correct path for your plugin manager
	local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
	vim.opt.rtp:append(snacks)
	require("snacks.profiler").startup({
		startup = {
			event = "VimEnter", -- stop profiler on this event. Defaults to `VimEnter`
			-- event = "UIEnter",
			-- event = "VeryLazy",
		},
	})
end

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
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- ── Initialise lazy.nvim ──────────────────────────────────────────────────
require("lazy").setup({
	spec = { { import = "plugins" } }, -- loads all specs from lua/plugins/**/*.lua
	defaults = { lazy = true }, -- all plugins lazy by default; opt-out per spec
	install = { colorscheme = { "default" } }, -- safe fallback before rose-pine is installed
	checker = { enabled = false }, -- no automatic update checks
})
