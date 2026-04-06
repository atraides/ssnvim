-- lua/config/options.lua — all vim.opt.* editor settings

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0

-- ── UI ────────────────────────────────────────────────────────────────────
vim.opt.number = true -- absolute line number on cursor line
vim.opt.relativenumber = true -- relative numbers everywhere else
vim.opt.signcolumn = "yes:1" -- always show sign column (prevents layout shift)
vim.opt.cursorline = true -- highlight the line the cursor is on
vim.opt.termguicolors = true -- 24-bit RGB colours (required for most colorschemes)
vim.opt.wrap = false -- no line wrapping
vim.opt.scrolloff = 8 -- keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8 -- keep 8 cols left/right of cursor
vim.opt.showmode = false -- mode shown in statusline (lualine), not cmdline

-- ── Indentation ───────────────────────────────────────────────────────────
vim.opt.expandtab = true -- spaces, not tabs
vim.opt.tabstop = 2 -- tab = 2 spaces
vim.opt.shiftwidth = 2 -- indent step = 2 spaces
vim.opt.softtabstop = 2 -- backspace deletes 2 spaces at once
vim.opt.smartindent = true -- auto-indent on new lines

-- ── Search ────────────────────────────────────────────────────────────────
vim.opt.ignorecase = true -- case-insensitive search
vim.opt.smartcase = true -- case-sensitive if pattern has uppercase
vim.opt.hlsearch = true -- highlight all matches (cleared with <Esc>)
vim.opt.incsearch = true -- live search preview as you type

-- ── Files & Undo ──────────────────────────────────────────────────────────
vim.opt.undofile = true -- persistent undo across sessions
vim.opt.swapfile = false -- no swap files
vim.opt.backup = false -- no backup files
vim.opt.updatetime = 250 -- faster CursorHold (used by LSP hover)
vim.opt.timeoutlen = 300 -- shorter wait for mapped key sequences

-- ── Splits ────────────────────────────────────────────────────────────────
vim.opt.splitbelow = true -- horizontal splits open below
vim.opt.splitright = true -- vertical splits open to the right

-- ── Clipboard ─────────────────────────────────────────────────────────────
vim.opt.clipboard = "unnamedplus" -- use system clipboard for all yank/paste

-- ── Visual indicators ─────────────────────────────────────────────────────
vim.opt.list = true -- show invisible characters
vim.opt.listchars = {
	tab = " ", -- tab character
	trail = "·", -- trailing space
	nbsp = "␣", -- non-breaking space
	eol = "󰌑", -- end-of-line
	multispace = "|   ", -- multispace
}
-- ── Completion ────────────────────────────────────────────────────────────
vim.opt.completeopt = { "menuone", "noselect" } -- blink.cmp compatible

-- ── Folds ─────────────────────────────────────────────────────────────────
-- treesitter-expression folding via Neovim 0.10+ native fold expr.
-- v:lua.vim.treesitter.foldexpr() returns "0" gracefully for buffers with
-- no treesitter parser (e.g. dashboard), so no errors occur on those buffers.
vim.opt.foldmethod = "expr" -- treesitter-expression folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- native Neovim 0.10+ fold expr
vim.opt.foldenable = false -- folds open by default

vim.diagnostic.config({ on_jump = { float = true } })
