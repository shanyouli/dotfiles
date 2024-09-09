{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
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
  config = with lib;
    mkIf cfg.enable {
      home.actionscript = ''
        echo-info "Synchronizing nvim configurations..."
        ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${config.dotfiles.configDir}/nvim/ ${config.home.configDir}/nvim/
      '';
      home.configFile."nvim/plugin_list.lua".text = mkIf (cfg.lsp != []) ''
        return {
          ${concatMapStringsSep ",\n" (v: ''"${v}"'') cfg.lsp}
        }
      '';
      env.MANPAGER = "nvim +Man!";
      # @https://discourse.nixos.org/t/stuck-writing-my-first-package/19022/4
      user.packages = [
        # (pkgs.lunarvim.override {
        #   nvimAlias = true;
        #   viAlias = true;
        #   vimAlias = true;
        # })
        (mkIf (cfg.enGui && pkgs.stdenvNoCC.isLinux) pkgs.unstable.neovide)
      ];
      home.programs.neovim = {
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
          telescope-fzf-native-nvim
          nvim-treesitter.withAllGrammars
        ];
      };
    };
}
