-- Customize Treesitter
-- --------------------
-- Treesitter customizations are handled with AstroCore
-- as nvim-treesitter simply provides a download utility for parsers

if _G.nix and _G.nix.treesitter_install_dir then vim.opt.runtimepath:prepend(_G.nix.treesitter_install_dir) end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true, -- enable/disable treesitter based highlighting
      indent = true, -- enable/disable treesitter based indentation
      parser_install_dir = _G.nix and _G.nix.treesitter_install_dir or nil,
      auto_install = not (_G.nix and _G.nix.treesitter_install_dir), -- Nix provides parsers when available
      ensure_installed = _G.nix and _G.nix.treesitter_install_dir and {} or {
        "lua",
        "vim",
        -- add more arguments for adding more treesitter parsers
      },
    },
  },
}
