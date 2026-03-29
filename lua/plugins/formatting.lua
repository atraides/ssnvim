-- lua/plugins/formatting.lua — format-on-save runner
-- conform.nvim runs standalone formatters (goimports, stylua, shfmt, ruff_format).
-- yaml and helm have no standalone formatter — lsp_format = "fallback" delegates to yamlls / helm_ls.
-- All binaries already installed by mason.nvim (lsp.lua lines 26–35).

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },

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
      -- Only filetypes with a standalone conform formatter are listed.
      -- yaml and helm are absent: lsp_format = "fallback" in format_on_save
      -- delegates to yamlls / helm_ls for those buffers automatically.
      formatters_by_ft = {
        python = { "ruff_format" },   -- ruff replaces black + isort
        go     = { "goimports" },     -- goimports = gofmt + import management
        lua    = { "stylua" },
        sh     = { "shfmt" },
        bash   = { "shfmt" },
        zsh    = { "shfmt" },
      },

      -- ── Format on save ────────────────────────────────────────────────
      -- Runs synchronously before BufWritePre completes (blocking, but fast).
      -- lsp_format = "fallback": if no conform formatter is configured for the
      -- current filetype, ask the LSP server to format instead.
      -- timeout_ms: 500ms is generous; stylua/shfmt are typically < 50ms.
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },

    },
  },
}
