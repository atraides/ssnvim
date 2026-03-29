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
  --
  -- lazy = false: blink must be loaded at startup because lua/plugins/lsp.lua calls
  -- require("blink.cmp").get_lsp_capabilities() when BufReadPre fires (before InsertEnter).
  --
  -- fang2hou/blink-copilot is declared as a dependency (no top-level spec needed).
  -- It has no setup() of its own; it registers itself as a blink source module.
  {
    "saghen/blink.cmp",
    lazy         = false,
    version      = "1.*",
    dependencies = { "fang2hou/blink-copilot" },
    opts_extend  = { "sources.default" },

    opts = {

      -- ── Keymaps ───────────────────────────────────────────────────────────
      -- preset = "default" provides: C-n/C-p navigate, C-e dismiss, C-y accept.
      -- Additional overrides add Tab/S-Tab (item navigation + snippet jump) and
      -- CR (accept) and C-space (force trigger).
      keymap = {
        preset      = "default",
        ["<Tab>"]   = { "select_next",     "snippet_forward",  "fallback" },
        ["<S-Tab>"] = { "select_prev",     "snippet_backward", "fallback" },
        ["<CR>"]    = { "accept",          "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },

      -- ── Completion behaviour ──────────────────────────────────────────────
      completion = {
        -- Ghost text: inline preview of the selected item (dim, non-intrusive).
        -- Copilot suggestions appear as blink source items, not as separate ghost text.
        ghost_text = { enabled = true },
        -- Documentation popup: show on item select (not on hover delay).
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },

      -- ── Sources ───────────────────────────────────────────────────────────
      -- Priority order (left = highest): lsp > path > snippets > buffer > copilot.
      -- score_offset = 100 on copilot boosts it above buffer/path but lsp scores
      -- are naturally higher (~1000+) so lsp items still appear first.
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

    },
  },

}
