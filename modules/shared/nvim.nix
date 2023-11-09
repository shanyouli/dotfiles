{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.nvim;
in {
  options = with lib; {
    my.modules.nvim = {
      enable = mkEnableOption "Whether to enable nvim module";
      enGui = mkEnableOption "Whether to enable GUI vim";
    };
  };
  # 使用lazyvim为基本配置: https://github.com/LazyVim/starter
  config = with lib;
    mkIf cfg.enable {
      my.user.packages = [pkgs.neovim (mkIf cfg.enGui pkgs.neovide)];
      environment.shellAliases = {
        vim = "nvim";
        vi = "nvim";
        v = "nvim";
      };
      # @https://discourse.nixos.org/t/stuck-writing-my-first-package/19022/4
      my.hm.configFile = let
        lazyvimSrc = pkgs.lazyvim-star.out;
      in {
        "nvim" = {
          source = "${lazyvimSrc}";
          recursive = true;
        };
        "nvim/lua/plugins/colorscheme.lua".source = "${configDir}/nvim/colorscheme.lua";
      };
    };
}
