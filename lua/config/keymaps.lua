-- lua/config/keymaps.lua — non-plugin keymaps only
-- LSP keymaps go in lua/plugins/lsp.lua (LspAttach autocmd).
-- Plugin-specific keymaps go in their plugin spec keys = {} table.

-- ── Utility ───────────────────────────────────────────────────────────────
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- ── Window navigation ─────────────────────────────────────────────────────
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- ── Window resize ─────────────────────────────────────────────────────────
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- ── Buffer navigation ─────────────────────────────────────────────────────
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- ── Scrolling — keep cursor centred ──────────────────────────────────────
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centred)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centred)" })

-- ── Move lines in visual mode ─────────────────────────────────────────────
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- ── Better indenting in visual mode (stay in visual) ─────────────────────
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- ── Paste / delete without clobbering register ────────────────────────────
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking selection" })
vim.keymap.set({ "n", "v" }, "<leader>dd", '"_d', { desc = "Delete without yanking" })

-- ── Quickfix navigation ───────────────────────────────────────────────────
vim.keymap.set("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })

-- ── Diagnostic navigation ─────────────────────────────────────────────────
-- Works without LSP (e.g. nvim-lint diagnostics). The LSP diagnostic float
-- (<leader>ld) is registered buffer-locally in plugins/lsp.lua LspAttach.
-- Override Neovim's built-in [d/]d — they jump but don't open the float.
-- vim.diagnostic.jump() is the non-deprecated replacement for goto_prev/goto_next.
-- on_jump fires after the cursor has moved, so open_float() lands on the diagnostic.
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({
		count = -1,
		on_jump = function(diagnostic, bufnr)
			if not diagnostic then
				return
			end
			vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
		end,
	})
end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({
		count = 1,
		on_jump = function(diagnostic, bufnr)
			if not diagnostic then
				return
			end
			vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
		end,
	})
end, { desc = "Next diagnostic" })
-- NOTE: Diffview keymaps (<leader>g*) live in lua/plugins/git.lua init function.
