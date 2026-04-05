-- lua/plugins/formatting.lua — format-on-save runner
return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },

		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "Format buffer",
			},
		},

		opts = {
			-- ── Per-filetype formatters ────────────────────────────────────────
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "goimports", "gofmt", stop_after_first = true },
				python = { "ruff_format", "black", stop_after_first = true },
				json = { "biome", "prettier", stop_after_first = true },
				markdown = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				toml = { "taplo" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
			},
			formatters = {
				biome = { require_cwd = true },
			},
			default_format_opts = {
				lsp_format = "fallback",
			},

			-- ── Format on save ────────────────────────────────────────────────
			-- Runs synchronously before BufWritePre completes (blocking, but fast).
			-- lsp_format = "fallback": if no conform formatter is configured for the
			-- current filetype, ask the LSP server to format instead.
			-- timeout_ms: 500ms is generous; stylua/shfmt are typically < 50ms.
			format_on_save = function(bufnr)
				local ignore_filetypes = { "sql", "yaml", "yml" }
				if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
					return
				end
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				if bufname:match("/node_modules/") then
					return
				end
				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
		},
	},
}
