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
  cfp = config.modules.gui;
  cfg = cfp.localsend;
in
{
  options.modules.gui.localsend = {
    enable = mkEnableOption "Whether to use localsend";
  };
  config = mkIf (cfp.enable && cfg.enable) { home.packages = [ pkgs.localsend ]; };
}
