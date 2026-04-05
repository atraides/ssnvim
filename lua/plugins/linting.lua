-- lua/plugins/linting.lua — async linting runner
-- nvim-lint runs linters outside the LSP protocol and surfaces results as vim.diagnostic entries.
-- Python excluded: ruff LSP (lsp.lua) already provides diagnostics.
-- Helm excluded: helm_ls provides template diagnostics.
-- All binaries already installed by mason.nvim (lsp.lua lines 31–35).

return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufWritePost", "BufReadPost" },

		-- nvim-lint has no setup() that accepts linters_by_ft.
		-- linters_by_ft must be set on the module directly; autocmd wires the trigger.
		-- config = function() is required — opts = {} alone does nothing.
		config = function()
			local lint = require("lint")

			-- ── Per-filetype linters ──────────────────────────────────────────
			-- Key: vim filetype string (same as vim.bo.filetype).
			-- Value: list of linter names matching filenames in nvim-lint's linters/ dir.
			-- IMPORTANT: use underscore names, not hyphen (golangci_lint, not golangci-lint).
			lint.linters_by_ft = {
				go = { "golangci_lint" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
				yaml = { "yamllint" },
				-- NOTE: "github-actions" is NOT reached via try_lint()'s compound-filetype
				-- auto-split path. yaml.github-actions buffers are handled explicitly in
				-- the autocmd below to prevent yamllint from also running on workflow files
				-- (Actions-specific syntax like ${{ }} is not valid plain YAML).
				["github-actions"] = { "actionlint" },
			}

			-- ── Lint trigger ─────────────────────────────────────────────────
			-- BufReadPost: lint when a file is opened (shows existing issues immediately).
			-- BufWritePost: lint after every save (picks up new issues instantly).
			-- try_lint() without args splits compound filetypes on ".", so for
			-- yaml.github-actions it would run both yamllint ("yaml" component) and
			-- actionlint ("github-actions" component). The guard below prevents that.
			local lint_group = vim.api.nvim_create_augroup("ssnvim_lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
				group = lint_group,
				callback = function()
					if vim.bo.filetype == "yaml.github-actions" then
						-- Explicitly run only actionlint; yamllint is skipped to avoid false
						-- positives on Actions-specific syntax (${{ expressions }}, etc.).
						lint.try_lint("actionlint")
					else
						lint.try_lint()
					end
				end,
			})

			-- FileType trigger for yaml.github-actions — fixes a lazy-load timing bug:
			-- when a workflow file is the FIRST buffer opened, BufReadPost fires before
			-- nvim-lint is loaded (loading it), so the autocmd above doesn't catch that
			-- first buffer. FileType fires later in the pipeline, after all plugins are
			-- loaded, ensuring actionlint runs even on direct open.
			vim.api.nvim_create_autocmd("FileType", {
				group = lint_group,
				pattern = "yaml.github-actions",
				callback = function()
					lint.try_lint("actionlint")
				end,
			})
		end,
	},
}
