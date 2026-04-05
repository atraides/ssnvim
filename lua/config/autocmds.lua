-- lua/config/autocmds.lua — autocommands for filetype detection and QoL

-- ── Helm filetype detection ───────────────────────────────────────────────
vim.filetype.add({
	pattern = {
		[".*/templates/.*%.yaml"] = "helm",
		[".*/templates/.*%.yml"] = "helm",
		[".*/templates/.*%.tpl"] = "helm",
		["helmfile.*%.yaml"] = "helm",
	},
})

-- ── Highlight on yank ─────────────────────────────────────────────────────
local yank_group = vim.api.nvim_create_augroup("ssnvim_yank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,
	desc = "Highlight yanked text briefly",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

-- ── Trailing whitespace trim ──────────────────────────────────────────────
-- Excluded for markdown — two trailing spaces are a significant line-break there.
local trim_group = vim.api.nvim_create_augroup("ssnvim_trim", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = trim_group,
	desc = "Remove trailing whitespace on save (except markdown)",
	callback = function()
		if vim.bo.filetype == "markdown" then
			return
		end
		local view = vim.fn.winsaveview()
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})

-- ── Restore cursor position ───────────────────────────────────────────────
-- pcall guards against error on fresh files with no saved mark.
local cursor_group = vim.api.nvim_create_augroup("ssnvim_cursor", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
	group = cursor_group,
	desc = "Restore cursor to last known position",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line_count = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- ── Resize splits on terminal resize ─────────────────────────────────────
local resize_group = vim.api.nvim_create_augroup("ssnvim_resize", { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
	group = resize_group,
	desc = "Equalize split sizes when terminal is resized",
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})
