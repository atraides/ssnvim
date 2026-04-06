-- lua/plugins/treesitter.lua — syntax highlighting, indentation, incremental selection

return {

	-- ── Treesitter: syntax highlighting + textobjects ────────────────────────
	-- nvim-treesitter-textobjects is an inline dependency so it loads together
	-- with nvim-treesitter on the first BufReadPost/BufNewFile — no separate
	-- lazy trigger needed, and no require() calls in an init hook (which would
	-- defeat lazy loading by forcing the plugin to load at startup).
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"Hdoc1509/gh-actions.nvim",
			{
				-- Must live here as a dependency so it loads together with nvim-treesitter.
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
			},
		},
		config = function()
			-- gh-actions must register its custom treesitter source BEFORE parsers
			-- are installed. Order here is critical.
			require("gh-actions.tree-sitter").setup()

			require("nvim-treesitter").setup({})
			require("nvim-treesitter").install({
				"python",
				"go",
				"gomod",
				"bash",
				"yaml",
				"helm",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"regex",
				"dockerfile",
				"gh_actions_expressions", -- injected grammar for ${{ }} expression highlighting
			})

			-- ── nvim-treesitter-textobjects setup ─────────────────────────────────
			require("nvim-treesitter-textobjects").setup({
				select = {
					enable = true,
					lookahead = true, -- jump to the next match if not currently inside one
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
					},
					include_surrounding_whitespace = false,
				},
				move = {
					enable = true,
					set_jumps = true, -- add moves to the jumplist
				},
			})

			-- ── Select keymaps ────────────────────────────────────────────────────
			local sel = require("nvim-treesitter-textobjects.select")
			for _, map in ipairs({
				{ { "x", "o" }, "af", "@function.outer" },
				{ { "x", "o" }, "if", "@function.inner" },
				{ { "x", "o" }, "ac", "@class.outer" },
				{ { "x", "o" }, "ic", "@class.inner" },
				{ { "x", "o" }, "aa", "@parameter.outer" },
				{ { "x", "o" }, "ia", "@parameter.inner" },
				{ { "x", "o" }, "ad", "@comment.outer" },
				{ { "x", "o" }, "as", "@statement.outer" },
			}) do
				vim.keymap.set(map[1], map[2], function()
					sel.select_textobject(map[3], "textobjects")
				end, { desc = "Select " .. map[3] })
			end

			-- ── Move keymaps ──────────────────────────────────────────────────────
			-- NOTE: ]] / [[ are used here for class navigation. snacks.nvim also
			-- binds ]] / [[ for word reference jumping, but those bindings are
			-- intentionally omitted from snacks.lua — these textobjects bindings
			-- are the authoritative definition. See plugins/snacks.lua for details.
			local mv = require("nvim-treesitter-textobjects.move")
			for _, map in ipairs({
				{ { "n", "x", "o" }, "]m", mv.goto_next_start, "@function.outer" },
				{ { "n", "x", "o" }, "[m", mv.goto_previous_start, "@function.outer" },
				{ { "n", "x", "o" }, "]]", mv.goto_next_start, "@class.outer" },
				{ { "n", "x", "o" }, "[[", mv.goto_previous_start, "@class.outer" },
				{ { "n", "x", "o" }, "]M", mv.goto_next_end, "@function.outer" },
				{ { "n", "x", "o" }, "[M", mv.goto_previous_end, "@function.outer" },
				{ { "n", "x", "o" }, "]o", mv.goto_next_start, { "@loop.inner", "@loop.outer" } },
				{ { "n", "x", "o" }, "[o", mv.goto_previous_start, { "@loop.inner", "@loop.outer" } },
			}) do
				local modes, lhs, fn, query = map[1], map[2], map[3], map[4]
				local qstr = (type(query) == "table") and table.concat(query, ",") or query
				vim.keymap.set(modes, lhs, function()
					fn(query, "textobjects")
				end, { desc = "Move to " .. qstr })
			end
		end,
	},
}
