-- ── Add vim plugins ───────────────────────────────────────────────────────
vim.pack.add({
	"https://github.com/atraides/neovim-ayu",
	"https://github.com/f-person/auto-dark-mode.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/folke/noice.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/lewis6991/gitsigns.nvim",
})

-- ── Colorscheme: Ayu ──────────────────────────────────────────────────────
require("ayu").setup({
	mirage = true,
	terminal = true,
	overrides = {},
})

local colors = require("ayu.colors")
local ayuline = require("ayu.lualine")

-- ── Auto dark/light mode (macOS appearance sync) ──────────────────────────
require("auto-dark-mode").setup({
	update_interval = 1000,
	set_dark_mode = function()
		vim.cmd("colorscheme ayu-mirage")
	end,
	set_light_mode = function()
		vim.cmd("colorscheme ayu-light")
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

require("lualine").setup(lualine_config)

require("noice").setup({
  -- lsp = {
  --   -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
  --   override = {
  --     ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
  --     ["vim.lsp.util.stylize_markdown"] = true,
  --     ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
  --   },
  -- },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})

local wk = require("which-key")
wk.setup({
	preset = "helix",
})
wk.add({
	-- { "<leader><tab>", group = "tabs" },
	-- { "<leader>c", group = "code" },
	-- { "<leader>d", group = "debug" },
	-- { "<leader>D", group = "Diffview", icon = { icon = "", color = "orange" } },
	{ "<leader>p", group = "Yanky", icon = { icon = "󰃮 ", color = "yellow" } },
	-- { "<leader>dp", group = "profiler" },
	{ "<leader>f", group = "file/find" },
	{ "<leader>g", group = "git" },
	{ "<leader>gh", group = "hunks" },
	{ "<leader>q", group = "quit/session" },
	{ "<leader>s", group = "search" },
	{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
	{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
	{ "[", group = "prev" },
	{ "]", group = "next" },
	{ "g", group = "goto" },
	{ "gs", group = "surround" },
	{ "z", group = "fold" },
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
	-- better descriptions
	{ "gx", desc = "Open with system app" },
	{
		"<leader>fC",
		group = "Copy Path",
		{
			"<leader>fCf",
			function()
				vim.fn.setreg("+", vim.fn.expand("%:p")) -- Copy full file path to clipboard
				vim.notify("Copied full file path: " .. vim.fn.expand("%:p"))
			end,
			desc = "Copy full file path",
		},
		{
			"<leader>fCn",
			function()
				vim.fn.setreg("+", vim.fn.expand("%:t")) -- Copy file name to clipboard
				vim.notify("Copied file name: " .. vim.fn.expand("%:t"))
			end,
			desc = "Copy file name",
		},
		{
			"<leader>fCr",
			function()
				local cwd = vim.fn.getcwd() -- Current working directory
				local full_path = vim.fn.expand("%:p") -- Full file path
				local rel_path = full_path:sub(#cwd + 2) -- Remove cwd prefix and leading slash
				vim.fn.setreg("+", rel_path) -- Copy relative file path to clipboard
				vim.notify("Copied relative file path: " .. rel_path)
			end,
			desc = "Copy relative file path",
		},
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Keymaps (which-key)",
		},
		{
			"<c-w><space>",
			function()
				require("which-key").show({ keys = "<c-w>", loop = true })
			end,
			desc = "Window Hydra Mode (which-key)",
		},
	},
	{
		-- Nested mappings are allowed and can be added in any order
		-- Most attributes can be inherited or overridden on any level
		-- There's no limit to the depth of nesting
		mode = { "n", "v" }, -- NORMAL and VISUAL mode
		{ "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
		{ "<leader>w", "<cmd>w<cr>", desc = "Write" },
	},
})
