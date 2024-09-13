-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },
        ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },

        -- Terminal
        -- NOTE: https://neovim.io/doc/user/builtin.html#jobstart()
        --   1. If {cmd} is a List it runs directly (no 'shell')
        --   2. If {cmd} is a String it runs in the 'shell'
        -- search and replace globally
        ["<Leader>ss"] = { '<cmd>lua require("spectre").toggle()<CR>', desc = "Toggle Spectre" },
        ["<Leader>sw"] = {
          '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
          desc = "Search current word",
        },
        ["<Leader>sp"] = {
          '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
          desc = "Search on current file",
        },

        -- yank_history
        ["<Leader>yh"] = {
          function() require("telescope").extensions.yank_history.yank_history() end,
          desc = "Preview Yank History",
        },

        -- undo history
        ["<Leader>uh"] = { "<cmd>Telescope undo<cr>", desc = "Telescope undo" },

        -- implementation/definition preview
        ["gpd"] = {
          "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
          desc = "goto_preview_definition",
        },
        ["gpt"] = {
          "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
          desc = "goto_preview_type_definition",
        },
        ["gpi"] = {
          "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
          desc = "goto_preview_implementation",
        },
        ["gP"] = { "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "close_all_win" },
        ["gpr"] = {
          "<cmd>lua require('goto-preview').goto_preview_references()<CR>",
          desc = "goto_preview_references",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },
      -- Visual mode
      v = {
        -- search and replace globally
        ["<Leader>sw"] = {
          '<esc><cmd>lua require("spectre").open_visual()<CR>',
          desc = "Search current word",
        },
      },
    },
  },
}
