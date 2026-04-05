-- lua/plugins/formatting.lua — format-on-save runner
return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		init = function()
			-- ── FormatDisable / FormatEnable user commands ────────────────────
			-- Bang variant (!): buffer-local disable. Without bang: global disable.
			vim.api.nvim_create_user_command("FormatDisable", function(opts)
				if opts.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
				vim.notify("Autoformat disabled" .. (opts.bang and " (buffer)" or " (global)"), vim.log.levels.WARN)
			end, { desc = "Disable autoformat-on-save", bang = true })

			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
				vim.notify("Autoformat enabled", vim.log.levels.INFO)
			end, { desc = "Re-enable autoformat-on-save" })

			-- ── Format keymaps ────────────────────────────────────────────────
			-- auto_format mirrors global state; toggled by <leader>uf.
			local auto_format = true
			vim.keymap.set("n", "<leader>uf", function()
				auto_format = not auto_format
				if auto_format then
					vim.cmd("FormatEnable")
				else
					vim.cmd("FormatDisable")
				end
			end, { desc = "Toggle Autoformat" })

			vim.keymap.set({ "n", "v" }, "<leader>cn", "<cmd>ConformInfo<cr>", { desc = "Conform Info" })

			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				require("conform").format({ async = true }, function(err, did_edit)
					if not err and did_edit then
						vim.notify("Code formatted", vim.log.levels.INFO, { title = "Conform" })
					end
				end)
			end, { desc = "Format buffer" })

			vim.keymap.set({ "n", "v" }, "<leader>cF", function()
				require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
			end, { desc = "Format Injected Langs" })
		end,
		config = function()
			require("conform").setup({
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
			})
		end,
	},
}
