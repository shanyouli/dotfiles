-- Customize Mason plugins

---@type LazySpec
return {
	-- use mason-lspconfig to configure LSP installations
	{
		"williamboman/mason-lspconfig.nvim",
		-- overrides `require("mason-lspconfig").setup(...)`
		-- mason is unusable on NixOS, disable it.
		-- ensure_installed nothing
		opts = function(_, opts)
			opts.ensure_installed = nil
			opts.automatic_installation = false
		end,
		-- opts = {
		--   ensure_installed = {
		--     "lua_ls",
		--     -- add more arguments for adding more language servers
		--   },
		-- },
	},
	-- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
	{
		"jay-babu/mason-null-ls.nvim",
		-- overrides `require("mason-null-ls").setup(...)`
		-- ensure_installed nothing
		opts = function(_, opts)
			opts.ensure_installed = nil
			opts.automatic_installation = false
		end,
		-- opts = {
		--   ensure_installed = {
		--     "stylua",
		--     -- add more arguments for adding more null-ls sources
		--   },
		-- },
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		-- overrides `require("mason-nvim-dap").setup(...)`
		-- opts = {
		--   ensure_installed = {
		--     "python",
		--     -- add more arguments for adding more debuggers
		--   },
		-- },
	},
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			-- Where Mason should put its bin location in your PATH. Can be one of:
			-- - "prepend" (default, Mason's bin location is put first in PATH)
			-- - "append" (Mason's bin location is put at the end of PATH)
			-- - "skip" (doesn't modify PATH)
			---@type '"prepend"' | '"append"' | '"skip"'
			opts.PATH = "append" -- use mason's package only when no other package is found
		end,
	},
}
