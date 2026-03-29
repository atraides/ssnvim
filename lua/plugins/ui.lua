-- lua/plugins/ui.lua — colorscheme, OS-aware dark/light switching, statusline

-- ── Kubernetes context (cached) ───────────────────────────────────────────
-- Cached at module load; avoids calling io.popen on every statusline redraw.
-- Tradeoff: stale if kubectl context changes mid-session (acceptable for MVP).
local _k8s_ctx = nil
local function k8s_context()
  if _k8s_ctx == nil then
    local handle = io.popen("kubectl config current-context 2>/dev/null")
    if not handle then
      _k8s_ctx = ""
    else
      _k8s_ctx = handle:read("*a"):gsub("\n", "")
      handle:close()
    end
  end
  return _k8s_ctx ~= "" and ("⎈ " .. _k8s_ctx) or ""
end

return {

  -- ── Colorscheme: Rosé Pine ──────────────────────────────────────────────
  -- Loaded eagerly (lazy=false) and at highest priority so it is applied
  -- before any other plugin can render with the wrong colours.
  -- auto-dark-mode.nvim handles variant switching (moon↔dawn) at runtime.
  {
    "rose-pine/neovim",
    name     = "rose-pine",   -- alias required; repo slug "neovim" collides with Neovim runtime
    lazy     = false,
    priority = 1000,
    opts     = {},             -- use rose-pine defaults; no palette overrides for MVP
    config   = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd("colorscheme rose-pine") -- initial load; auto-dark-mode overrides on first poll
    end,
  },

  -- ── Auto dark/light mode (macOS appearance sync) ────────────────────────
  -- Polls `defaults read -g AppleInterfaceStyle` every update_interval ms.
  -- Switches between rose-pine-moon (dark) and rose-pine-dawn (light).
  {
    "f-person/auto-dark-mode.nvim",
    lazy   = false,
    config = function()
      require("auto-dark-mode").setup({
        update_interval = 1000,                                       -- poll every 1 s
        set_dark_mode   = function() vim.cmd("colorscheme rose-pine-moon") end,
        set_light_mode  = function() vim.cmd("colorscheme rose-pine-dawn") end,
      })
    end,
  },

  -- ── Statusline: lualine ─────────────────────────────────────────────────
  -- theme = "rose-pine" auto-matches the active colorscheme variant.
  -- lualine_z right-side includes the cached K8s context component.
  {
    "nvim-lualine/lualine.nvim",
    lazy   = false,
    config = function()
      require("lualine").setup({
        options = {
          theme                = "rose-pine",
          globalstatus         = true,   -- single statusline for all windows
          section_separators   = "",     -- no powerline arrows — clean minimal look
          component_separators = "│",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },  -- path=1 → show relative path
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location", k8s_context },
        },
      })
    end,
  },

}
