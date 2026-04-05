-- lua/plugins/completion.lua — completion engine + GitHub Copilot
-- blink.cmp replaces nvim-cmp. Uses a pre-built Rust fuzzy-matching binary (version = "1.*").
-- copilot.lua provides the Copilot LSP backend; blink-copilot bridges it into blink.cmp.

return {

	-- ── SPEC 1: copilot.lua — GitHub Copilot backend ─────────────────────────
	-- Connects to the Copilot LSP server. Must load before Insert mode so the
	-- LSP client is authenticated and attached before the first keystroke.
	-- suggestion and panel are disabled: blink.cmp handles all completion display.
	{
	  "zbirenbaum/copilot.lua",
	  cmd   = "Copilot",       -- allow :Copilot auth / :Copilot status from normal mode
	  event = "InsertEnter",   -- attach LSP client on first insert (not needed at startup)
	  opts  = {
	    suggestion = { enabled = false },  -- disable inline ghost text — blink handles this
	    panel      = { enabled = false },  -- disable copilot panel
	  },
	},

	-- ── SPEC 2: blink.cmp — completion engine ────────────────────────────────
	-- version = "1.*": downloads the pre-built Rust binary from a release tag.
	-- Do NOT use version = "main" or omit version — that requires a local Rust toolchain.
	{
		"saghen/blink.cmp",
		lazy = false,
		version = "1.*",
		dependencies = { "fang2hou/blink-copilot" },
		opts_extend = { "sources.default" },

		opts = {
			keymap = { preset = "super-tab" },
			appearance = {
				nerd_font_variant = "mono",
				use_nvim_cmp_as_default = true,
			},

			-- ── Completion behaviour ──────────────────────────────────────────────
			completion = {
				documentation = { auto_show = false },
				ghost_text = { enabled = true },
			},

			-- ── Sources ───────────────────────────────────────────────────────────
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "copilot" },
				providers = {
				  copilot = {
				    name         = "copilot",
				    module       = "blink-copilot",
				    score_offset = 100,
				    async        = true,
				    opts         = {
				      max_completions = 3,      -- show up to 3 Copilot suggestions at a time
				      kind_icon       = " ",  -- icon shown in completion menu
				      kind_name       = "Copilot",
				      debounce        = 200,    -- ms before firing a Copilot request
				    },
				  },
				},
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
	},
}
