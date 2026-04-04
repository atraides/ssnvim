-- ── Add vim plugins ───────────────────────────────────────────────────────
vim.pack.add({
	"https://github.com/atraides/neovim-ayu",
	"https://github.com/f-person/auto-dark-mode.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

-- ── Colorscheme: Ayu ──────────────────────────────────────────────────────
require("ayu").setup({
	mirage = true,
	terminal = true,
	overrides = {},
})

local colors = require("ayu.colors")

-- ── Auto dark/light mode (macOS appearance sync) ──────────────────────────
require("auto-dark-mode").setup({
	update_interval = 1000,
	set_dark_mode = function()
		vim.cmd("colorscheme ayu-mirage")
		colors.generate(true)
	end,
	set_light_mode = function()
		vim.cmd("colorscheme ayu-light")
		colors.generate()
	end,
})

-- ── Lualine setup ──────────────────────────────────────────────────────────
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
		local mode_color = {
			n = colors.blue,
			i = colors.green,
			v = colors.magenta,
			[" "] = colors.blue,
			V = colors.magenta,
			c = colors.warning,
			no = colors.warning,
			s = colors.opeator,
			S = colors.operator,
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
	icon = "󰊢",
	color = function()
    return { fg = colors.green, gui = "bold" }
  end,
})

ins_left({
	"filename",
	cond = conditions.buffer_not_empty,
	color = function()
    return { fg = colors.magenta, gui = "bold" }
  end,
	padding = { right = 0, left = 0 },
})

ins_left({
	"diff",
	-- Is it me or the symbol for modified us really weird
	symbols = { added = " ", modified = " ", removed = " " },
	diff_color = {
		added = { fg = colors.vcs_added },
		modified = { fg = colors.vcs_modified },
		removed = { fg = colors.vcs_removed },
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
		info = { fg = colors.cyan },
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
	color = { fg = colors.black, gui = "bold" },
})

ins_right({ "location" })

ins_right({
  "progress",
  color = function()
    return { fg = colors.fg, gui = "bold" }
  end,
})

ins_right({
	function()
		return "▊"
	end,
	color = function()
    return { fg = colors.blue }
  end,
	padding = { left = 1 },
})

require("lualine").setup(lualine_config)
