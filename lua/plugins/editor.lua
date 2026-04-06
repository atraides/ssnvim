-- lua/plugins/editor.lua — oil.nvim, gitsigns, which-key, flash, treesj, mini.surround, mini.pairs

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
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				-- Enhanced f, t, F, T motions
				char = {
					enabled = true,
					jump_labels = true,
				},
			},
		},
		keys = {
			{
				"m",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"M",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},
	{
		"Wansmer/treesj",
		keys = { "<space>m", "<space>j", "<space>k" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesj").setup({})
		end,
	},
	{
		"nvim-mini/mini.surround",
		version = false,
		keys = {
			{ "sa", mode = { "n", "x" }, desc = "Add Surrounding" },
			{ "sd", mode = "n", desc = "Delete Surrounding" },
			{ "sr", mode = "n", desc = "Replace Surrounding" },
			{ "sf", mode = "n", desc = "Find Surrounding" },
			{ "sF", mode = "n", desc = "Find Left Surrounding" },
			{ "sh", mode = "n", desc = "Highlight Surrounding" },
		},
		config = function()
			require("mini.surround").setup({})
		end,
	},
	{
		"nvim-mini/mini.pairs",
		version = false,
		event = "InsertEnter",
		config = function()
			require("mini.pairs").setup({})
		end,
	},
}
