{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.gui;
  cfg = cfp.localsend;
in {
  options.modules.gui.localsend = {
    enable = mkEnableOption "Whether to use localsend";
  };
  config = mkIf (cfp.enable && cfg.enable) {
    user.packages = [pkgs.localsend];
  };
}
