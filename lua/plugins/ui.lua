-- lua/plugins/ui.lua — colorscheme, OS-aware dark/light switching, statusline

return {

	-- ── Colorscheme: Ayu ──────────────────────────────────────────────
	-- Loaded eagerly (lazy=false) and at highest priority so it is applied
	-- before any other plugin can render with the wrong colours.
	-- auto-dark-mode.nvim handles variant switching (mirage↔light) at runtime.
	{
		"atraides/neovim-ayu",
		name = "neovim-ayu", -- alias required; repo slug "neovim" collides with Neovim runtime
		lazy = false,
		priority = 1000,
		opts = {
      mirage = true,
      terminal = true,
      overrides = {},
    },
		config = function(_, opts)
      require("ayu").setup({
        vim.cmd("colorscheme ayu") -- initial load; auto-dark-mode overrides on first poll
      })
		end,
	},

	-- ── Auto dark/light mode (macOS appearance sync) ────────────────────────
	-- Polls `defaults read -g AppleInterfaceStyle` every update_interval ms.
	-- Switches between rose-pine-moon (dark) and rose-pine-dawn (light).
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		config = function()
			require("auto-dark-mode").setup({
				update_interval = 1000, -- poll every 1 s
				set_dark_mode = function()
					vim.cmd("colorscheme ayu-mirage")
				end,
				set_light_mode = function()
					vim.cmd("colorscheme ayu-light")
				end,
			})
		end,
	},

	-- ── Statusline: lualine ─────────────────────────────────────────────────
	-- theme = "rose-pine" auto-matches the active colorscheme variant.
	-- lualine_z right-side includes the cached K8s context component.
	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		config = function()
      local colors = require("ayu.colors")
      local ayuline = require("ayu.lualine")
      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand("%:p:h")
          local gitdir = vim.fn.finddir(".git", filepath .. ";")
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }
      local lualine_config = {
        options = {
          icons_enabled = true,
          -- Disable sections and component separators
          component_separators = "",
          section_separators = "",
          theme = "auto",
        },
        sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          -- These will be filled later
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      -- Inserts a component in lualine_c at left section
      local function ins_left(component)
        table.insert(lualine_config.sections.lualine_c, component)
      end

      -- Inserts a component in lualine_x at right section
      local function ins_right(component)
        table.insert(lualine_config.sections.lualine_x, component)
      end

      ins_left({
        -- mode component
        function()
          return ""
        end,
        color = function()
          return ayuline.mode_color(vim.fn.mode(),colors)
        end,
        padding = { left = 1, right = 1 },
      })

      ins_left({
        "branch",
        icon = "󰊢",
        color = ayuline.styles["branch"],
      })

      ins_left({
        "filename",
        cond = conditions.buffer_not_empty,
        color = ayuline.styles["filename"],
      })

      ins_left({
        "diff",
        -- Is it me or the symbol for modified us really weird
        symbols = { added = " ", modified = " ", removed = " " },
        diff_color = ayuline.styles["diff"],
        cond = conditions.hide_in_width,
      })

      ins_left({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = ayuline.styles["diagnostics"],
      })

      ins_right({
        "lsp_status",
        icon = "󰣖", -- f013
        symbols = {
          spinner = {},
          -- Standard unicode symbol for when LSP is done:
          done = "",
          -- Delimiter inserted between LSP names:
          separator = ", ",
        },
        -- List of LSP names to ignore (e.g., `null-ls`):
        ignore_lsp = { "stylua" },
        -- Display the LSP name
        show_name = true,
        color = ayuline.styles["lsp_status"],
      })

      ins_right({
        "location",
        color = ayuline.styles["location"],
      })

      ins_right({
        "progress",
        color = ayuline.styles["progress"],
      })

      ins_right({
        function()
          return "▊"
        end,
        color = ayuline.styles["line_close"],
        padding = { left = 1 },
      })

			require("lualine").setup({
        options = {
          icons_enabled = true,
          -- Disable sections and component separators
          component_separators = "",
          section_separators = "",
          theme = "auto",
        },
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } }, -- path=1 → show relative path
					lualine_x = { "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
    require("lualine").setup(lualine_config)
		end,
	},
  	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("noice").setup({
				-- lsp = {
				-- 	-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				-- 	override = {
				-- 		["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				-- 		["vim.lsp.util.stylize_markdown"] = true,
				-- 		["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				-- 	},
				-- },
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = true, -- add a border to hover docs and signature help
				},
			})
		end,
	},
}
