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
  cfp = config.modules.fonts;
  cfg = config.modules.network.localsend;
in
{
  options.modules.network.localsend = {
    enable = mkEnableOption "Whether to use localsend";
  };
  config = mkIf (cfp.enable && cfg.enable) { home.packages = [ pkgs.localsend ]; };
}
