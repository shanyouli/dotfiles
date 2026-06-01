{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.app.editor.nvim;

  parserRevision =
    dep:
    let
      depName = dep.name or (builtins.baseNameOf (toString dep));
      revMatch = builtins.match ".*\\+rev=([^+]+)$" depName;
    in
    if revMatch != null then builtins.head revMatch else dep.version or depName;

  pluginSpecs = [
    {
      repo = "folke/lazy.nvim";
      pkg = pkgs.vimPlugins.lazy-nvim;
    }
    {
      repo = "AstroNvim/astrocore";
      pkg = pkgs.vimPlugins.astrocore;
    }
    {
      repo = "AstroNvim/astrolsp";
      pkg = pkgs.vimPlugins.astrolsp;
    }
    {
      repo = "AstroNvim/astroui";
      pkg = pkgs.vimPlugins.astroui;
    }
    {
      repo = "AstroNvim/astrotheme";
      pkg = pkgs.vimPlugins.astrotheme;
    }
    {
      repo = "MunifTanjim/nui.nvim";
      pkg = pkgs.vimPlugins.nui-nvim;
    }
    {
      repo = "folke/snacks.nvim";
      pkg = pkgs.vimPlugins.snacks-nvim;
    }
    {
      repo = "folke/todo-comments.nvim";
      pkg = pkgs.vimPlugins.todo-comments-nvim;
    }
    {
      repo = "folke/which-key.nvim";
      pkg = pkgs.vimPlugins.which-key-nvim;
    }
    {
      repo = "folke/lazydev.nvim";
      pkg = pkgs.vimPlugins.lazydev-nvim;
    }
    {
      repo = "nvim-lua/plenary.nvim";
      pkg = pkgs.vimPlugins.plenary-nvim;
    }
    {
      repo = "nvim-tree/nvim-web-devicons";
      pkg = pkgs.vimPlugins.nvim-web-devicons;
    }
    {
      repo = "echasnovski/mini.statusline";
      pkg = pkgs.vimPlugins.mini-statusline;
    }
    {
      repo = "nvim-neo-tree/neo-tree.nvim";
      pkg = pkgs.vimPlugins.neo-tree-nvim;
    }
    {
      repo = "nvimdev/dashboard-nvim";
      pkg = pkgs.vimPlugins.dashboard-nvim;
    }
    {
      repo = "rcarriga/nvim-notify";
      pkg = pkgs.vimPlugins.nvim-notify;
    }
    {
      repo = "rebelot/heirline.nvim";
      pkg = pkgs.vimPlugins.heirline-nvim;
    }
    {
      repo = "lukas-reineke/indent-blankline.nvim";
      pkg = pkgs.vimPlugins.indent-blankline-nvim;
    }
    {
      repo = "folke/noice.nvim";
      pkg = pkgs.vimPlugins.noice-nvim;
    }
    {
      repo = "stevearc/resession.nvim";
      pkg = pkgs.vimPlugins.resession-nvim;
    }
    {
      repo = "kevinhwang91/nvim-ufo";
      pkg = pkgs.vimPlugins.nvim-ufo;
    }
    {
      repo = "kevinhwang91/promise-async";
      pkg = pkgs.vimPlugins.promise-async;
    }
    {
      repo = "max397574/better-escape.nvim";
      pkg = pkgs.vimPlugins.better-escape-nvim;
    }
    {
      repo = "RRethy/vim-illuminate";
      pkg = pkgs.vimPlugins.vim-illuminate;
    }
    {
      repo = "andweeb/presence.nvim";
      pkg = pkgs.vimPlugins.presence-nvim;
    }
    {
      repo = "ray-x/lsp_signature.nvim";
      pkg = pkgs.vimPlugins.lsp_signature-nvim;
    }
    {
      repo = "lewis6991/gitsigns.nvim";
      pkg = pkgs.vimPlugins.gitsigns-nvim;
    }
    {
      repo = "EdenEast/nightfox.nvim";
      pkg = pkgs.vimPlugins.nightfox-nvim;
    }
    {
      repo = "nvim-tree/nvim-tree.lua";
      pkg = pkgs.vimPlugins.nvim-tree-lua;
    }
    {
      repo = "nvim-treesitter/nvim-treesitter";
      pkg = pkgs.vimPlugins.nvim-treesitter;
    }
    {
      repo = "akinsho/bufferline.nvim";
      pkg = pkgs.vimPlugins.bufferline-nvim;
    }
    {
      repo = "onsails/lspkind.nvim";
      pkg = pkgs.vimPlugins.lspkind-nvim;
    }
    {
      repo = "saghen/blink.cmp";
      pkg = pkgs.vimPlugins.blink-cmp;
    }
    {
      repo = "rafamadriz/friendly-snippets";
      pkg = pkgs.vimPlugins.friendly-snippets;
    }
    {
      repo = "L3MON4D3/LuaSnip";
      pkg = pkgs.vimPlugins.luasnip;
    }
    {
      repo = "windwp/nvim-autopairs";
      pkg = pkgs.vimPlugins.nvim-autopairs;
    }
    {
      repo = "williamboman/mason.nvim";
      pkg = pkgs.vimPlugins.mason-nvim;
    }
    {
      repo = "williamboman/mason-lspconfig.nvim";
      pkg = pkgs.vimPlugins.mason-lspconfig-nvim;
    }
    {
      repo = "jay-babu/mason-nvim-dap.nvim";
      pkg = pkgs.vimPlugins.mason-nvim-dap-nvim;
    }
    {
      repo = "jay-babu/mason-null-ls.nvim";
      pkg = pkgs.vimPlugins.mason-null-ls-nvim;
    }
    {
      repo = "WhoIsSethDaniel/mason-tool-installer.nvim";
      pkg = pkgs.vimPlugins.mason-tool-installer-nvim;
    }
    {
      repo = "neovim/nvim-lspconfig";
      pkg = pkgs.vimPlugins.nvim-lspconfig;
    }
    {
      repo = "stevearc/conform.nvim";
      pkg = pkgs.vimPlugins.conform-nvim;
    }
    {
      repo = "mfussenegger/nvim-lint";
      pkg = pkgs.vimPlugins.nvim-lint;
    }
    {
      repo = "nvimtools/none-ls.nvim";
      pkg = pkgs.vimPlugins.none-ls-nvim;
    }
    {
      repo = "nvim-telescope/telescope.nvim";
      pkg = pkgs.vimPlugins.telescope-nvim;
    }
    {
      repo = "nvim-telescope/telescope-fzf-native.nvim";
      pkg = pkgs.vimPlugins.telescope-fzf-native-nvim;
    }
    {
      repo = "numToStr/Comment.nvim";
      pkg = pkgs.vimPlugins.comment-nvim;
    }
  ];

  pluginPairs = map (spec: {
    name = last (splitString "/" spec.repo);
    path = spec.pkg;
  }) pluginSpecs;

  pluginsOptionType =
    with types;
    listOf (oneOf [
      package
      (submodule {
        options = {
          name = mkOption { type = str; };
          path = mkOption { type = package; };
        };
      })
    ]);

  treesitPackage =
    let
      inherit (builtins)
        attrNames
        filter
        isList
        isString
        ;
      inherit (pkgs.vimPlugins) nvim-treesitter nvim-treesitter-parsers;
    in
    if isString cfg.treesit then
      if cfg.treesit == "all" then
        let
          ignore-list = [ "org" ];
          all-treesit = attrNames (
            lib.filterAttrs (
              name: value: (!(elem name ignore-list) && lib.isDerivation value)
            ) nvim-treesitter-parsers
          );
        in
        nvim-treesitter.withPlugins (plugins: attrVals all-treesit plugins)
      else if builtins.hasAttr cfg.treesit nvim-treesitter-parsers then
        nvim-treesitter.withPlugins (plugins: attrVals [ cfg.treesit ] plugins)
      else
        null
    else if isList cfg.treesit then
      let
        parserStrings = filter isString cfg.treesit;
        parserPackages = filter isDerivation cfg.treesit;
      in
      nvim-treesitter.withPlugins (plugins: (attrVals parserStrings plugins) ++ parserPackages)
    else
      null;

  finalPlugins =
    (map (spec: spec.pkg) pluginSpecs)
    ++ optional (treesitPackage != null) treesitPackage
    ++ cfg.plugins;
  lazyPluginFarm = pkgs.linkFarm "nvim-lazy-plugins" pluginPairs;
  treesitSitePackage =
    if treesitPackage == null then
      null
    else
      pkgs.runCommandLocal "nvim-treesitter-site" { } ''
        mkdir -p "$out/parser" "$out/parser-info"

        if [ -d "${treesitPackage}/queries" ]; then
          ln -s "${treesitPackage}/queries" "$out/queries"
        fi

        ${lib.concatMapStringsSep "\n" (
          dep:
          let
            revision = parserRevision dep;
            parserDir = "${dep}/parser";
          in
          ''
            if [ -d "${parserDir}" ]; then
              for parser in "${parserDir}"/*.so; do
                [ -e "$parser" ] || continue
                name=$(basename "$parser")
                lang=''${name%.so}
                ln -sf "$parser" "$out/parser/$name"
                printf '%s\n' '${revision}' > "$out/parser-info/$lang.revision"
              done
            fi
          ''
        ) treesitPackage.dependencies}
      '';
in
{
  options.modules.app.editor.nvim = with types; {
    enable = mkEnableOption "Whether to enable nvim module";
    enGui = mkBoolOpt config.modules.gui.enable;
    plugins = mkOption {
      type = pluginsOptionType;
      default = [ ];
    };
    treesit = mkOption {
      default = "all";
      type = oneOf [
        (nullOr str)
        (listOf (oneOf [
          str
          package
        ]))
      ];
      description = "优先使用 nixpkgs 提供的 treesitter parser。";
    };
  };

  config = mkIf cfg.enable {
    env.MANPAGER = "nvim +Man!";

    my.user.init.SyncNvim = ''
      ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my.paths.dotfiles.config}/nvim/ ${config.home.configDir}/nvim/
    '';

    home = {
      configFile."nvim/nix.lua".text = ''
        _G.use_nix = true
        _G.nix = {
          lazy_plugin_dir = ${builtins.toJSON "${lazyPluginFarm}"},
          treesitter_install_dir = ${
            if treesitPackage == null then "nil" else builtins.toJSON "${config.home.dataDir}/nvim/site"
          },
        }
      '';

      dataFile."nvim/site" = mkIf (treesitSitePackage != null) {
        source = treesitSitePackage;
        recursive = true;
      };

      packages = [
        (mkIf cfg.enGui pkgs.neovide)
        pkgs.glow # markdown tui
        pkgs.tree-sitter
        (mkIf (!config.modules.dev.nix.enable) pkgs.nil)
      ]
      ++ optionals (!config.modules.dev.lua.enable) [
        pkgs.lua-language-server
        pkgs.stylua
      ]
      ++ optionals (!config.modules.dev.bash.enable) [
        pkgs.shfmt
        pkgs.shellcheck
      ];

      programs.neovim = {
        enable = true;
        package = pkgs.neovim-unwrapped;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        withPython3 = true;
        withRuby = true;
        plugins = finalPlugins;
        extraWrapperArgs = with pkgs; [
          "--suffix"
          "LIBRARY_PATH"
          ":"
          "${lib.makeLibraryPath [
            stdenv.cc.cc
            zlib
          ]}"
          "--suffix"
          "PKG_CONFIG_PATH"
          ":"
          "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
            stdenv.cc.cc
            zlib
          ]}"
        ];
      };
    };
  };
}
