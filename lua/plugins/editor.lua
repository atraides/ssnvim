-- lua/plugins/editor.lua — oil.nvim, gitsigns, which-key, nvim-autopairs

return {

  -- ── File manager: oil.nvim ───────────────────────────────────────────────
  -- Edits the filesystem like a buffer. `-` opens the parent directory of the
  -- current file. `g?` inside oil shows all oil keybindings.
  -- lazy=false: `-` must work from the first buffer (including dashboard/scratch).
  -- If lazy-loaded via keys, the first press triggers load but does nothing.
  {
    "stevearc/oil.nvim",
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {},  -- oil defaults are sufficient for MVP
  },

  -- ── Git decorations: gitsigns.nvim ──────────────────────────────────────
  -- Shows added/changed/removed line signs in the sign column.
  -- Hunk navigation and operations registered per-buffer via on_attach.
  -- BufReadPre: attach before buffer renders so signs appear on the first frame.
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },

      -- on_attach: buffer-local keymaps — only active in Git-tracked buffers.
      -- Defined here (not in keymaps.lua) so they don't pollute non-git buffers.
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Hunk navigation — mirrors ]d/[d diagnostic navigation convention.
        -- vim.wo.diff guard: in diff mode, use native ]c/[c instead of gitsigns.
        vim.keymap.set("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.next_hunk()
          end
        end, { buffer = bufnr, desc = "Next hunk" })

        vim.keymap.set("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.prev_hunk()
          end
        end, { buffer = bufnr, desc = "Prev hunk" })

        -- Hunk operations (<leader>g* — git group)
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk,                { buffer = bufnr, desc = "Stage hunk"        })
        vim.keymap.set("n", "<leader>gr", gs.reset_hunk,                { buffer = bufnr, desc = "Reset hunk"        })
        vim.keymap.set("n", "<leader>gp", gs.preview_hunk,              { buffer = bufnr, desc = "Preview hunk"      })
        vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle line blame" })

        -- Visual-mode partial hunk staging/reset (operate on selected lines only)
        vim.keymap.set("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { buffer = bufnr, desc = "Stage hunk (visual)" })

        vim.keymap.set("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { buffer = bufnr, desc = "Reset hunk (visual)" })
      end,
    },
  },

  -- ── Keybinding discovery: which-key.nvim ────────────────────────────────
  -- Displays available keybindings when a prefix key is held.
  -- VeryLazy: no need to load before first render; saves startup time.
  -- Uses which-key v3 spec format — do NOT use the v2 register() API.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      -- Register group names for all <leader>* prefix groups.
      -- <leader>l and <leader>c are defined here even though their keymaps
      -- are added in Phase 5 (LSP) and Phase 7 (format/lint) respectively.
      -- which-key shows the group label; individual keymaps populate it later.
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
        { "<leader>f", group = "find"     },
        { "<leader>g", group = "git"      },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
        { "z", group = "fold" },
      },
    },
  },
}
