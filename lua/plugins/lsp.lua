-- lua/plugins/lsp.lua — full LSP stack: mason + mason-lspconfig + lspconfig + schemastore

return {
	-- ── SPEC 1: Mason — automated tool installer ────────────────────────────
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()

			local registry = require("mason-registry")
			local tools = {
				-- Formatters (Phase 7 — conform.nvim)
				"black", -- python formatting
				"goimports", -- go import management + formatting
				"shfmt", -- shell formatting
				"stylua", -- lua formatting
				"prettier", -- js/ts/html/css formatting
				"taplo", -- toml formatting
				-- Linters (Phase 7 — nvim-lint)
				"golangci-lint", -- go multi-linter
				"shellcheck", -- shell linting
				"yamllint", -- yaml linting
				"actionlint", -- github actions linting
			}
			registry.refresh(function()
				for _, name in ipairs(tools) do
					local ok, pkg = pcall(registry.get_package, name)
					if ok and not pkg:is_installed() then
						pkg:install()
					end
				end
			end)
		end,
	},

	-- ── SPEC 4: nvim-lspconfig (main config spec) ──────────────────────────
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"b0o/schemastore.nvim",
		},
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- ── A. Diagnostic display config ────────────────────────────────────
			vim.diagnostic.config({
				virtual_text = { spacing = 4, prefix = "󰅁" },
				signs = true,
				underline = true,
				update_in_insert = false, -- don't interrupt typing with diagnostic updates
				severity_sort = true,
				float = { border = "rounded", source = true },
			})

			-- ── B. Capabilities — applied globally to all servers ───────────────
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", { capabilities = capabilities })

			-- ── C. LspAttach keymaps ─────────────────────────────────────────────
			-- Buffer-local keymaps registered only when an LSP client attaches.
			-- NOTE: [d, ]d, <leader>e are already defined in keymaps.lua — not duplicated here.
			-- NOTE: <leader>l group is already registered in editor.lua which-key spec.
			local lsp_group = vim.api.nvim_create_augroup("ssnvim_lsp", { clear = true })
			vim.api.nvim_create_autocmd("LspAttach", {
				group = lsp_group,
				callback = function(event)
					local map = function(keys, fn, desc)
						vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc })
					end

					-- Navigation — standard Neovim LSP conventions (no leader prefix)
					map("gd", vim.lsp.buf.definition, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gI", vim.lsp.buf.implementation, "Go to implementation")
					map("K", vim.lsp.buf.hover, "Hover documentation")
					map("gr", vim.lsp.buf.references, "Find references")

					-- <leader>l group — LSP operations (group label set in editor.lua which-key)
					map("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>la", vim.lsp.buf.code_action, "Code action")
					map("<leader>lf", function()
						vim.lsp.buf.format({ async = true })
					end, "Format buffer (LSP)")
				end,
			})

			-- ── D. Per-server config via vim.lsp.config() ───────────────────────
			-- Only servers needing non-default config are listed here.
			-- gopls and ruff get no overrides — nvim-lspconfig defaults are sufficient.
			-- All servers are started automatically by mason-lspconfig's automatic_enable.

			-- ── pyright — Python type checking + completions ─────────────────────
			vim.lsp.config("pyright", {
				before_init = function(_, config)
					local cwd = vim.fn.getcwd()
					for _, candidate in ipairs({ "/.venv/bin/python", "/venv/bin/python" }) do
						local path = cwd .. candidate
						if vim.fn.executable(path) == 1 then
							config.settings = config.settings or {}
							config.settings.python = config.settings.python or {}
							config.settings.python.pythonPath = path
							return
						end
					end
				end,
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "strict", -- not "strict" — practical balance
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			-- ── bashls — Bash/sh/zsh completions and hover ───────────────────────
			-- Default filetypes are sh and bash; zsh added explicitly.
			vim.lsp.config("bashls", {
				filetypes = { "bash", "sh", "zsh" },
			})

			-- ── yamlls — YAML intelligence + SchemaStore (CRITICAL: no helm) ─────
			-- CRITICAL: "helm" must NOT appear in filetypes.
			-- autocmds.lua sets ft=helm for templates/*.yaml via vim.filetype.add() —
			-- this runs before BufRead autocmds and before LSP attach. If "helm" were
			-- listed here, yamlls would attach to Helm buffers and conflict with helm_ls.
			vim.lsp.config("yamlls", {
				filetypes = { "yaml", "yaml.docker-compose" },
				settings = {
					yaml = {
						-- Disable built-in schema store; use schemastore.nvim catalog instead.
						-- Provides K8s, ArgoCD, Helm values, GitHub Actions schemas.
						schemaStore = { enable = false, url = "" },
						schemas = require("schemastore").yaml.schemas(),
						validate = true,
						completion = true,
						hover = true,
					},
				},
			})

			-- ── helm_ls — Helm template intelligence ─────────────────────────────
			-- Explicit filetypes guard: only attaches to ft=helm buffers (set by autocmds.lua).
			-- helm_ls internally spawns its own yaml-language-server for values files;
			-- point it at the Mason-installed binary so it uses a consistent version.
			vim.lsp.config("helm_ls", {
				filetypes = { "helm" },
				settings = {
					["helm-ls"] = {
						yamlls = { path = "yaml-language-server" },
					},
				},
			})

			-- ── gh_actions_ls — GitHub Actions expression-aware completions ─────────
			-- Default filetypes = { 'yaml' } — overridden to yaml.github-actions so
			-- the server only attaches to workflow files, not all YAML buffers.
			-- Do NOT set init_options here — the nvim-lspconfig default already has
			-- init_options = {} which the server requires; vim.lsp.config() merges, not
			-- replaces, so the default init_options stays in place automatically.
			-- root_dir scopes to .github/workflows/ and does not need overriding.
			--
			-- flags.allow_incremental_sync = false: gh_actions_ls occasionally sends
			-- completion textEdit items whose line positions exceed the buffer's actual
			-- line count. Neovim's incremental diff in vim/lsp/sync.lua then tries to
			-- index a non-existent line and crashes ("attempt to get length of local
			-- 'prev_line' (a nil value)"). Forcing full-document sync bypasses that
			-- code path entirely. Workflow files are short (<500 lines) so the overhead
			-- of sending the full document on every change is negligible.
			vim.lsp.config("gh_actions_ls", {
				filetypes = { "yaml.github-actions" },
				flags = { allow_incremental_sync = false },
			})

			-- ── lua_ls — Lua intelligence for Neovim config ───────────────────────
			-- Neovim runtime added to workspace.library so vim.* resolves without errors.
			-- checkThirdParty = false suppresses the "configure this project?" prompt.
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" }, -- Neovim uses LuaJIT
						workspace = {
							checkThirdParty = false,
							library = vim.api.nvim_get_runtime_file("", true),
						},
						diagnostics = {
							globals = { "vim" }, -- suppress "undefined global 'vim'" warnings
						},
						telemetry = { enable = false },
					},
				},
			})

			-- ── E. mason-lspconfig setup ─────────────────────────────────────────
			-- ensure_installed uses lspconfig server names (underscores), NOT mason
			-- package names (hyphens). mason-lspconfig handles the name mapping internally.
			-- automatic_enable = true (the default) calls vim.lsp.enable() for each
			-- installed server — no explicit lspconfig[name].setup() calls needed.
			require("mason-lspconfig").setup({
				ensure_installed = {
					"biome", -- JSON formatting + linting
					"pyright", -- python type checking
					"ruff", -- python linting + code actions
					"gopls", -- go
					"bashls", -- bash/sh/zsh (mason pkg: bash-language-server)
					"yamlls", -- yaml (mason pkg: yaml-language-server)
					"helm_ls", -- helm (mason pkg: helm-ls)
					"lua_ls", -- lua (mason pkg: lua-language-server)
					"gh_actions_ls", -- github actions (mason pkg: gh-actions-language-server)
				},
			})
		end,
	},
}
