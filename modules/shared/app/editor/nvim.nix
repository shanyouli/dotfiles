{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfg = config.modules.app.editor.nvim;
in {
  options = with lib; {
    modules.app.editor.nvim = {
      enable = mkEnableOption "Whether to enable nvim module";
      enGui = mkBoolOpt config.modules.gui.enable;
      script = mkStrOpt "";
      lsp = with types; mkOpt' (listOf str) [] "nvim 安装的 lsp 服务";
    };
  };
  # 使用lazyvim为基本配置: https://github.com/LazyVim/starter
  config = mkIf cfg.enable {
    env.MANPAGER = "nvim +Man!";
    home = {
      actionscript = ''
        echo-info "Synchronizing nvim configurations..."
        ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my.dotfiles.config}/nvim/ ${config.home.configDir}/nvim/
      '';
      configFile."nvim/nix.lua".text = ''
        _G.use_nix = true;
        _G.nix = {
          lazypath = "${pkgs.unstable.vimPlugins.lazy-nvim}",
          tressitSoPath = "${config.home.dataDir}/nvim-treesit-parsers",
        }
        vim.opt.runtimepath:prepend("${config.home.dataDir}/nvim-treesit-parsers/parser")
      '';
      dataFile."nvim-treesit-parsers" = {
        source = let
          treesit-so-path = pkgs.symlinkJoin {
            name = "treesitter-parsers";
            paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
          };
        in
          treesit-so-path;
        recursive = true;
      };
      # configFile."nvim/plugin_list.lua".text = ''        return {
      #           ${concatMapStringsSep ",\n" (v: ''"${v}"'') cfg.lsp}
      #         }
      # '';
      # @https://discourse.nixos.org/t/stuck-writing-my-first-package/19022/4
      packages = [
        # (pkgs.lunarvim.override {
        #   nvimAlias = true;
        #   viAlias = true;
        #   vimAlias = true;
        # })
        (mkIf (cfg.enGui && pkgs.stdenvNoCC.isLinux) pkgs.unstable.neovide)
        pkgs.glow
      ];
      programs.neovim = {
        enable = true;
        package = pkgs.unstable.neovim-unwrapped;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        extraWrapperArgs = with pkgs; [
          # LIBRARY_PATH is used by gcc before compilation to search directories
          # containing static and shared libraries that need to be linked to your program.
          "--suffix"
          "LIBRARY_PATH"
          ":"
          "${lib.makeLibraryPath [stdenv.cc.cc zlib]}"

          # PKG_CONFIG_PATH is used by pkg-config before compilation to search directories
          # containing .pc files that describe the libraries that need to be linked to your program.
          "--suffix"
          "PKG_CONFIG_PATH"
          ":"
          "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [stdenv.cc.cc zlib]}"
        ];
        # NOTE: These plugins will not be used by astronvim by default!
        # We should install packages that will compile locally or download FHS binaries via Nix!
        # and use lazy.nvim's `dir` option to specify the package directory in nix store.
        # so that these plugins can work on NixOS.
        #
        # related project:
        #  https://github.com/b-src/lazy-nix-helper.nvim
        plugins = with pkgs.vimPlugins; [
          # search all the plugins using https://search.nixos.org/packages
          pkgs.unstable.vimPlugins.lazy-nvim # nvim 包管理器
          telescope-fzf-native-nvim
          nvim-treesitter.withAllGrammars
        ];
      };
    };
  };
}
