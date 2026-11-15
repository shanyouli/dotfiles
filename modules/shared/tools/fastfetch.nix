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
  cfg = config.modules.tools.fastfetch;
in
{
  options.modules.tools.fastfetch = {
    enable = mkEnableOption "Whether to use fastfetch";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.fastfetch ]; };
}
