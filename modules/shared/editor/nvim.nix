{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.editor.nvim;
in {
  options = with lib; {
    modules.editor.nvim = {
      enable = mkEnableOption "Whether to enable nvim module";
      enGui = mkBoolOpt config.modules.gui.enable;
      script = mkStrOpt "";
    };
  };
  # 使用lazyvim为基本配置: https://github.com/LazyVim/starter
  config = with lib;
    mkIf cfg.enable {
      # environment.shellAliases = {
      #   vim = "nvim";
      #   vi = "nvim";
      #   v = "nvim";
      # };
      env.MANPAGER = "nvim +Man!";
      # @https://discourse.nixos.org/t/stuck-writing-my-first-package/19022/4
      user.packages = [
        (pkgs.lunarvim.override {
          nvimAlias = true;
          viAlias = true;
          vimAlias = true;
        })
        (mkIf (cfg.enGui && pkgs.stdenvNoCC.isLinux) pkgs.unstable.neovide)
      ];
    };
}
