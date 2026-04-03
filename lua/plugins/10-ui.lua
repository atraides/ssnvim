-- ── Add vim plugins ───────────────────────────────────────────────────────
vim.pack.add({
  "https://github.com/atraides/neovim-ayu",
  "https://github.com/f-person/auto-dark-mode.nvim",
  "https://github.com/sontungexpt/witch-line",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

-- ── Colorscheme: Ayu ──────────────────────────────────────────────────────
require('ayu').setup({
  mirage = false,
    terminal = true,
    overrides = {},
})

ayu_colors = require("ayu.colors")

-- ── Auto dark/light mode (macOS appearance sync) ──────────────────────────
require("auto-dark-mode").setup({
  update_interval = 1000,
  set_dark_mode = function()
    vim.cmd("colorscheme ayu-dark")
    ayu_colors.generate()
  end,
  set_light_mode = function()
    vim.cmd("colorscheme ayu-light")
    ayu_colors.generate()
  end,
})

local ssnfile_name = require("witch-line.builtin").comp("file.name", {
  id = "ssnfile_name",
  padding = { left = 0, right = 1 },
  min_screen_width = 80,
  hidden = function()
    return vim.bo.buftype == "nofile"
  end,
  style = { fg = "text", bold = true },
})

local ssnmode = {
  id = "ssnmode",
  events = {"ModeChanged", "BufEnter", "BufRead"},
	flexible = 90,
  static = {
    mode_colors = {
      n = { fg = "Type" },
      [' '] = { fg = "Type" },
      no = { fg = "Label" },
      i = { fg = "String" },
      v = { fg = "Constant" },
      c = { fg = "Function" },
      cv = { fg = "Function" },
      ce = { fg = "Function" },
    },
  },
  update = function(self, sid)
		local static = self.static
		return "", static.mode_colors[vim.api.nvim_get_mode().mode]
	end,
}

-- ── Setup Statusline ──────────────────────────────────────────────────────
require("witch-line").setup({
  --- @type CombinedComponent[]
  statusline = {
    --- The global statusline components
    --- Set it to `nil` if you want to use default components in example
    global = {
        ssnmode,
        "git.branch",
        ssnfile_name,
    },

    -- @type fun(winid): CombinedComponent[]|nil
    win = nil
  },

  cache = {
      -- You can disable cache here.
      -- If you enable cache you can not use any up-value in your component functions otherwise your
      -- cache will be broken.
      enabled = true,
      -- Show notification when cache is cleared. Default true.
      notification = true,
      -- Strip debug info when caching dumped functions. Default false. Faster but harder to debug.
      func_strip = false,
  },

  disabled = {
    filetypes = { "help", "TelescopePrompt" },
    buftypes = { "nofile", "terminal" },
  },

  --- Whether to automatically adjust the theme.
  --- If it is set to false the `auto_theme` field of the component will be ignored.
  --- Default: true.
  --- You can toggle it by `:Witchline toggle_auto_theme`
  auto_theme = true

})
