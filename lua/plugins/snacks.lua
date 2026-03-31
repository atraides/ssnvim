-- lua/plugins/snacks.lua — snacks.nvim: picker, lazygit, terminal, dashboard, notifier, indent
-- snacks.nvim is a multi-tool by folke. One require("snacks").setup() call enables all modules.
-- The `Snacks` global is injected by snacks.nvim at load time — no require() needed in keys.

return {
	{
		"folke/snacks.nvim",
		-- Eager load: notifier must replace vim.notify before other plugins send notifications.
		-- If lazy-loaded, early startup messages bypass snacks and are lost.
		lazy = false,
		priority = 950, -- below rose-pine (1000) so colorscheme is applied first

		-- ── Keybindings ──────────────────────────────────────────────────────────
		-- All snacks pickers use the Snacks global (set by snacks.nvim at load time).
		-- <leader>f* = find/pick  |  <leader>g* = git  |  <leader>t* = terminal
		keys = {
			-- Find / pick
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Find buffers",
			},
			{
				"<leader>fh",
				function()
					Snacks.picker.help()
				end,
				desc = "Find help",
			},
			-- Note: lsp_symbols and diagnostics are no-ops until Phase 5 adds LSP.
			-- Include now so which-key shows them and keybindings are stable across phases.
			{
				"<leader>fs",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "Find LSP symbols",
			},
			{
				"<leader>fd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Find diagnostics",
			},
			-- Git
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Open lazygit",
			},
			-- Terminal
			{
				"<leader>tt",
				function()
					Snacks.terminal()
				end,
				desc = "Open terminal",
			},
			{
				"<leader>ps",
				function()
					Snacks.profiler.scratch()
				end,
				desc = "Profiler Scratch Bufer",
			},
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
						{ icon = "󰱼", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
						{ icon = "", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
						{ icon = "", key = "q", desc = "Quit", action = ":qa" },
					},
				},
			},

			-- ── Notifier ─────────────────────────────────────────────────────────
			-- Replaces vim.notify globally. Notifications appear as non-blocking
			-- floating toasts rather than blocking the command line.
			notifier = {},

			-- ── Dim ─────────────────────────────────────────────────────────
			dim = { enabled = true },

			-- ── Indent ───────────────────────────────────────────────────────────
			-- Visual indent guides on all buffers. Uses treesitter scope when available
			-- (Phase 4); falls back to indent-level heuristic until then.
			indent = {},

			-- ── Performance modules ──────────────────────────────────────────────
			-- bigfile:   disables expensive features (treesitter, indent) for files > 1.5 MB
			-- quickfile: faster file loading by bypassing some event overhead
			bigfile = { enabled = true },
			quickfile = { enabled = true },

			-- ── Disabled modules ─────────────────────────────────────────────────
			-- statuscolumn: options.lua sets signcolumn="yes"; snacks.statuscolumn would override it
			-- words:        not needed for MVP
			statuscolumn = { enabled = false },
			words = { enabled = false },
		},
	},
}
