-- lua/plugins/treesitter.lua — syntax highlighting, indentation, incremental selection

return {

  -- ── Treesitter: syntax highlighting + indent + incremental selection ────
  -- Uses config = function() because nvim-treesitter requires explicit
  -- require("nvim-treesitter.configs").setup() — opts = {} alone does nothing.
  -- Loads lazily on BufReadPost (existing files) and BufNewFile (new buffers).
  {
    "nvim-treesitter/nvim-treesitter",
    -- TODO: Eventually replace this with the rewritten branch and the universal loader which I used earlier
    branch = "master",     -- v1.0 main-branch rewrite removed nvim-treesitter.configs; master has the stable API
    build  = ":TSUpdate",  -- recompile grammars after install/update
    event  = { "BufReadPost", "BufNewFile" },
    dependencies = {
      -- gh-actions.nvim registers the gh_actions_expressions grammar.
      -- Must be a dependency (not a separate spec) so it loads before
      -- this config function runs.
      "Hdoc1509/gh-actions.nvim",
    },
    config = function()
      -- MUST precede nvim-treesitter.configs.setup() so the grammar is
      -- registered in the parser list before auto-install runs.
      require("gh-actions.tree-sitter").setup()

      require("nvim-treesitter.configs").setup({

        -- Parsers to install automatically on first launch.
        -- markdown_inline is always paired with markdown (handles inline code/bold/italic).
        -- helm uses the combined YAML + Go-template grammar — do NOT use gotmpl.
        ensure_installed = {
          "python",
          "go",
          "gomod",
          "bash",
          "yaml",
          "helm",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "dockerfile",
          "gh_actions_expressions",  -- injected grammar for ${{ }} expression highlighting
        },

        -- Never auto-install parsers for every filetype encountered.
        -- Keep the install list explicit.
        auto_install = false,

        -- ── Highlight ──────────────────────────────────────────────────────
        -- Replaces Neovim's regex-based ft highlighting with grammar-accurate
        -- highlighting. Helm files show Go-template expressions differently
        -- from surrounding YAML keys.
        highlight = { enable = true },

        -- ── Indent ─────────────────────────────────────────────────────────
        -- Enables the = operator to re-indent by treesitter grammar rather
        -- than by Neovim's built-in indentation heuristic.
        indent = { enable = true },

        -- ── Incremental selection ───────────────────────────────────────────
        -- <CR> in normal mode starts a visual selection on the current node.
        -- <CR> again expands to the parent node; <BS> shrinks back.
        -- scope_incremental disabled — not needed for MVP.
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection    = "<A-o>",   -- start selection on current node
            node_incremental  = "<A-o>",   -- expand to parent node
            node_decremental  = "<A-i>",   -- shrink to child node
            scope_incremental = false,    -- disable scope expansion
          },
        },

      })
    end,
  },

}
