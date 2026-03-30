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
        go   = { "golangci_lint" },
        sh   = { "shellcheck" },
        bash = { "shellcheck" },
        zsh  = { "shellcheck" },
        yaml = { "yamllint" },
        -- nvim-lint matches the suffix component of compound filetypes.
        -- "github-actions" fires for yaml.github-actions buffers only.
        -- "yaml" key also fires for those buffers (yamllint checks YAML syntax;
        -- actionlint checks Actions semantics) — both running is intentional.
        ["github-actions"] = { "actionlint" },
      }

      -- ── Lint trigger ─────────────────────────────────────────────────
      -- BufReadPost: lint when a file is opened (shows existing issues immediately).
      -- BufWritePost: lint after every save (picks up new issues instantly).
      -- try_lint() is non-blocking; it fires the linter and callbacks update diagnostics.
      local lint_group = vim.api.nvim_create_augroup("ssnvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group    = lint_group,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
