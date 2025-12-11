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
  cfp = config.modules.dev;
  cfg = cfp.scheme;
in
{
  options.modules.dev.scheme = {
    enable = mkEnableOption "Whether to use scheme";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.chez ]; };
}
