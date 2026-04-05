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
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- ── Quickfix navigation ───────────────────────────────────────────────────
vim.keymap.set("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })

-- ── Diagnostic navigation ─────────────────────────────────────────────────
-- Works without LSP (e.g. nvim-lint diagnostics); LSP adds more in plugins/lsp.lua
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Git status / changed files view
vim.keymap.set("n", "<leader>gd", "<Cmd>DiffviewOpen<CR>", { desc = "Diff: git status" })
-- File history views
vim.keymap.set("n", "<leader>gv", "<Cmd>DiffviewFileHistory<CR>", { desc = "Diff: repo history" })
vim.keymap.set("n", "<leader>gV", "<Cmd>DiffviewFileHistory %<CR>", { desc = "Diff: current file history" })

-- Visual mode: history of selected lines
vim.keymap.set("v", "<leader>gv", ":'<,'>DiffviewFileHistory<CR>", { desc = "Diff: selection history" })

-- Compare with revisions (prompts)
vim.keymap.set("n", "<leader>gc", function()
	vim.ui.input({ prompt = "Compare revision (ex. main, HEAD~5, main..HEAD): " }, function(refs)
		if refs and refs:match("%S") then
			vim.cmd(("DiffviewOpen %s"):format(refs))
		end
	end)
end, { desc = "Diff: compare revisions" })

vim.keymap.set("n", "<leader>gC", function()
	vim.ui.input({ prompt = "File history range (ex. HEAD~1, main..HEAD): " }, function(range)
		if range and range:match("%S") then
			vim.cmd(("DiffviewFileHistory --range=%s %%"):format(range))
		end
	end)
end, { desc = "Diff: file history with range" })

-- Compare two arbitrary files
vim.keymap.set("n", "<leader>g2", function()
	vim.ui.input({ prompt = "First file: " }, function(file1)
		if not file1 or not file1:match("%S") then
			return
		end
		vim.ui.input({ prompt = "Second file: " }, function(file2)
			if file2 and file2:match("%S") then
				vim.cmd(("tabnew | e %s | diffthis | vsplit %s | diffthis"):format(file1, file2))
			end
		end)
	end)
end, { desc = "Diff: Compare 2 files" })
