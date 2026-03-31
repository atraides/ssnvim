-- lua/plugins/ui.lua — colorscheme, OS-aware dark/light switching, statusline

return {

	-- ── Colorscheme: Rosé Pine ──────────────────────────────────────────────
	-- Loaded eagerly (lazy=false) and at highest priority so it is applied
	-- before any other plugin can render with the wrong colours.
	-- auto-dark-mode.nvim handles variant switching (moon↔dawn) at runtime.
	{
		"rose-pine/neovim",
		name = "rose-pine", -- alias required; repo slug "neovim" collides with Neovim runtime
		lazy = false,
		priority = 1000,
		opts = {}, -- use rose-pine defaults; no palette overrides for MVP
		config = function(_, opts)
			require("rose-pine").setup(opts)
			vim.cmd("colorscheme rose-pine") -- initial load; auto-dark-mode overrides on first poll
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"Shatur/neovim-ayu",
		lazy = false,
		priority = 1000,
		opts = {
			mirage = true,
		},
		config = function(_, opts)
			require("ayu").setup(opts)
			vim.cmd("colorscheme rose-pine") -- initial load; auto-dark-mode overrides on first poll
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
					vim.cmd("colorscheme tokyonight-night")
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
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		config = function()
			local colors = require("tokyonight.colors").setup()
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
					theme = "tokyonight-night",
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
					local mode_color = {
						n = colors.blue,
						i = colors.green1,
						v = colors.purple,
						[" "] = colors.blue,
						V = colors.purple,
						c = colors.warning,
						no = colors.warning,
						s = colors.orange,
						S = colors.orange,
						ic = colors.yellow,
						R = colors.green,
						Rv = colors.green,
						cv = colors.red,
						ce = colors.red,
						r = colors.cyan,
						rm = colors.cyan,
						["r?"] = colors.cyan,
						["!"] = colors.red,
						t = colors.red,
					}
					return { fg = mode_color[vim.fn.mode()] }
				end,
				padding = { left = 1, right = 1 },
			})

			ins_left({
				"branch",
				icon = "",
				color = { fg = colors.purple, gui = "bold" },
			})

			ins_left({
				"filetype",
				cond = conditions.buffer_not_empty,
				colored = true, -- Displays filetype icon in color if set to true
				icon_only = true, -- Display only an icon for filetype
				padding = { right = 0, left = 1 },
			})

			ins_left({
				"filename",
				cond = conditions.buffer_not_empty,
				color = { fg = colors.magenta, gui = "bold" },
				padding = { right = 1, left = 0 },
			})

			ins_left({
				"diff",
				-- Is it me or the symbol for modified us really weird
				symbols = { added = " ", modified = " ", removed = " " },
				diff_color = {
					added = { fg = colors.green },
					modified = { fg = colors.yellow },
					removed = { fg = colors.red },
				},
				cond = conditions.hide_in_width,
			})

			ins_left({
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = { error = " ", warn = " ", info = " " },
				diagnostics_color = {
					error = { fg = colors.error },
					warn = { fg = colors.warning },
					info = { fg = colors.info },
				},
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
				color = { fg = colors.dark3, gui = "bold" },
			})

			ins_right({ "location" })

			ins_right({ "progress", color = { fg = colors.fg, gui = "bold" } })

			ins_right({
				function()
					return "▊"
				end,
				color = { fg = colors.blue },
				padding = { left = 1 },
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
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
				},
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
			})
		end,
	},
}
