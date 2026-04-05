-- lua/plugins/editor.lua — oil.nvim, gitsigns, which-key, nvim-autopairs

return {

	-- ── File manager: oil.nvim ───────────────────────────────────────────────
	{
		"stevearc/oil.nvim",
		lazy = false,
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {}, -- oil defaults are sufficient for MVP
	},

	-- ── Git decorations: gitsigns.nvim ──────────────────────────────────────
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
		},
	},

	-- ── Keybinding discovery: which-key.nvim ────────────────────────────────
	-- Displays available keybindings when a prefix key is held.
	-- VeryLazy: no need to load before first render; saves startup time.
	-- Uses which-key v3 spec format — do NOT use the v2 register() API.
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			spec = {
				{
					"<leader>b",
					group = "buffer",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
				{
					"<leader>w",
					group = "windows",
					proxy = "<c-w>",
					expand = function()
						return require("which-key.extras").expand.win()
					end,
				},
			{ "<leader>f", group = "find" },
			{ "<leader>g", group = "git" },
			{ "<leader>t", group = "terminal" },
			{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
			{ "<leader>c", group = "code" },
			{ "<leader>l", group = "lsp" },
			{ "z", group = "fold" },
			},
		},
	},

	-- ── Auto-close brackets and quotes: nvim-autopairs ──────────────────────
	-- Pairs are inserted on the character that opens them, so InsertEnter is fine.
	-- Loads only when the user enters insert mode — saves startup time.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
}
