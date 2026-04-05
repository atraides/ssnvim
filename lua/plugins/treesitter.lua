-- lua/plugins/treesitter.lua — syntax highlighting, indentation, incremental selection

return {

  -- ── Treesitter: syntax highlighting + indent + incremental selection ────
  {
    "nvim-treesitter/nvim-treesitter",
    branch       = "main",
    build        = ":TSUpdate",
    event        = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "Hdoc1509/gh-actions.nvim",
    },
    config       = function()
      require("gh-actions.tree-sitter").setup()
      require("nvim-treesitter").setup({})
      require("nvim-treesitter").install({
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
        "gh_actions_expressions", -- injected grammar for ${{ }} expression highlighting
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          enable = true,
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V",  -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
          include_surrounding_whitespace = false,
        },
        move = {
          enable = true,
          set_jumps = true,
        },
      })
    end
  },
}
