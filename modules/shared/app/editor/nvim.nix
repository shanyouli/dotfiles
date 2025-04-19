# 根据 [AstroNvim](https://astronvim.com/) 整理配置
# 参考: https://github.com/azuwis/nix-config/blob/0d9ebcc82acf886ae013f822ec6ea3fcf03bb218/common/neovim/home.nix#L60
#       https://github.com/azuwis/nix-config/blob/0d9ebcc82acf886ae013f822ec6ea3fcf03bb218/common/lazyvim/base/default.nix#L1
#       https://github.com/LazyVim/LazyVim/discussions/1972
{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.app.editor.nvim;
  pluginsOptionType =
    let
      inherit (types)
        listOf
        oneOf
        package
        str
        submodule
        ;
    in
    listOf (oneOf [
      package
      (submodule {
        options = {
          name = mkOption { type = str; };
          path = mkOption { type = packages; };
        };
      })
    ]);
  treesit-list =
    let
      inherit (pkgs.vimPlugins) nvim-treesitter-parsers nvim-treesitter;
      inherit (builtins)
        isString
        isList
        filter
        elem
        attrNames
        ;
    in
    if isString cfg.treesit then
      (
        if cfg.treesit == "all" then
          # nvim-treesitter.withAllGrammars
          # NOTE: nvim-treesitter.withAllGrammars 中的 nu parser 目前存在问题，date: 2025.03.19
          #      org parser 和 norg parser 存在冲突，在 nvim 中推荐使用 norg parser。
          #      所以暂时不使用全部的 treesit
          (
            let
              ignore-list = [ "org" ];
              all-treesit = attrNames (
                lib.filterAttrs (name: v: (!(elem name ignore-list) && lib.isDerivation v)) nvim-treesitter-parsers
              );
            in
            nvim-treesitter.withPlugins (plugins: attrVals all-treesit plugins)
          )
        else if nvim-treesitter-parsers ? cfg.treesit then
          nvim-treesitter.withPlugins (plugins: attrVals [ cfg.treesit ] plugins)
        else
          null
      )
    else if isList cfg.treesit then
      (
        let
          parserStrings = filter isString cfg.treesit;
          parserPackages = filter isDerivation cfg.treesit;
        in
        nvim-treesitter.withPlugins (plugins: (attrVals parserStrings plugins) ++ parserPackages)
      )
    else
      null;
in
{
  options = with lib; {
    modules.app.editor.nvim = {
      enable = mkEnableOption "Whether to enable nvim module";
      enGui = mkBoolOpt config.modules.gui.enable;
      script = mkStrOpt "";
      plugins = mkOption {
        type = pluginsOptionType;
        default = [ ];
      };
      lsp = with types; mkOpt' (listOf str) [ ] "nvim 安装的 lsp 服务";

      # NOTE: 如果你希望使用 nixpkgs 中自带的 nvim 插件，lazy.enable 选项必须为 true;
      lazy.enable = mkBoolOpt true;
      lazy.spec = mkOption {
        type = types.lines;
        default = "";
      };
      # NOTE: 是否使用 nix 管理 treesit（语法高亮树）
      treesit = mkOption {
        default = null;
        type =
          with types;
          oneOf [
            (nullOr str)
            (listOf (oneOf [
              str
              package
            ]))
          ];
      };
      rc = mkOpt' types.lines "" ''
        nvim configurations
      '';
    };
  };
  # 使用lazyvim为基本配置: https://github.com/LazyVim/starter
  config = mkIf cfg.enable (mkMerge [
    {
      env.MANPAGER = "nvim +Man!";
      my.user.init.SyncNvim = ''
        ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my.dotfiles.config}/nvim/ ${config.home.configDir}/nvim/
      '';
      home = {
        configFile."nvim/nix.lua".text = ''
           -- -*- mode: lua; -*-
           _G.use_nix = true;
           _G.nix = {}
          -- 额外的自定义配置
          ${cfg.rc}
        '';
        # @https://discourse.nixos.org/t/stuck-writing-my-first-package/19022/4
        packages = [
          # https://github.com/NixOS/nixpkgs/pull/352727
          (mkIf cfg.enGui pkgs.neovide)
          pkgs.glow
        ];
        programs.neovim = {
          enable = true;
          package = pkgs.neovim-unwrapped;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          extraWrapperArgs = with pkgs; [
            # LIBRARY_PATH is used by gcc before compilation to search directories
            # containing static and shared libraries that need to be linked to your program.
            "--suffix"
            "LIBRARY_PATH"
            ":"
            "${lib.makeLibraryPath [
              stdenv.cc.cc
              zlib
            ]}"

            # PKG_CONFIG_PATH is used by pkg-config before compilation to search directories
            # containing .pc files that describe the libraries that need to be linked to your program.
            "--suffix"
            "PKG_CONFIG_PATH"
            ":"
            "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
              stdenv.cc.cc
              zlib
            ]}"
          ];
          # NOTE: These plugins will not be used by astronvim by default!
          # We should install packages that will compile locally or download FHS binaries via Nix!
          # and use lazy.nvim's `dir` option to specify the package directory in nix store.
          # so that these plugins can work on NixOS.
          #
          # related project:
          #  https://github.com/b-src/lazy-nix-helper.nvim
          inherit (cfg) plugins;
        };
      };
    }
    (mkIf cfg.lazy.enable {
      modules.app.editor.nvim = {
        plugins = with pkgs.vimPlugins; [
          # search all the plugins using https://search.nixos.org/packages
          telescope-fzf-native-nvim
          astrotheme
          lazy-nvim
        ];
        rc = mkOrder 10000 (
          let
            mkEntryFromDrv =
              drv:
              if isDerivation drv then
                {
                  name = "${lib.getName drv}";
                  path = drv;
                }
              else
                drv;
            # (lib.subtractLists cfg.excludePlugins cfg.plugins ++ cfg.extraPlugins)
            lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv cfg.plugins);
          in
          ''
            -- 使用 nix 包管理器管理 lazy-nvim 插件
            _G.nix.lazy = true
            require("lazy").setup({
              {
                "AstroNvim/AstroNvim",
                version = "^4", -- Remove version tracking to elect for nighly AstroNvim
                import = "astronvim.plugins",
                opts = { -- AstroNvim options must be set here with the `import` key
                  mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
                  maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
                  icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
                  pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
                },
              },
              { import = "community" },
              { import = "plugins" },
            },
            {
              ui = { backdrop = 100 },
              install = { colorscheme = { "astrotheme" } },
              check = {
                order = false,
              },
              performance = {
                rtp = {
                  -- disable some rtp plugins, add more to your liking
                  disabled_plugins = {
                    "gzip",
                    "netrwPlugin",
                    "tarPlugin",
                    "tohtml",
                    "zipPlugin",
                  },
                },
              },
              defaults = {
                lazy = true,
              },
              dev = {
                path = "${lazyPath}",
                patterns = { "" },
                fallback = true,
              },
              rocks = {
                enabled = false,
              },
              spec = {
                -- The following configs are needed for fixing lazyvim on nix
                -- force enable telescope-fzf-native.nvim
                { "nvim-telescope/telescope-fzf-native.nvim", dev = true,},
                {"AstroNvim/astrotheme", dev = true },
                -- 导入相关配置
                ${cfg.lazy.spec}
              },
            })
          ''
        );
      };
    })
    (mkIf (treesit-list != null) {
      modules.app.editor.nvim = {
        plugins = [ pkgs.vimPlugins.nvim-treesitter ];
        rc = ''_G.nix.treesit = true'';
        lazy.spec = ''
          -- treesitter handled by my.neovim.treesitterParsers, put this line at the end of spec to clear ensure_installed
          {
            "nvim-treesitter/nvim-treesitter",
            dev = true,
            opts = function(_, opts)
              opts.ensure_installed = {}
              opts.parser_install_dir = "${config.home.configDir}/nvim/parser"
            end
          },
        '';
      };
      home.configFile."nvim/parser" = {
        source =
          let
            parsers = pkgs.symlinkJoin {
              name = "treesitter-parsers";
              paths = treesit-list.dependencies;
            };
          in
          "${parsers}/parser";
        recursive = true;
      };
      # modules.app.editor.nvim.rc = ''
      #   _G.nix.treesitSoPath = "${config.home.dataDir}/nvim-treesit-parsers"
      #   vim.opt.runtimepath:prepend("${config.home.dataDir}/nvim-treesit-parsers/parser")
      # '';
    })
  ]);
}
