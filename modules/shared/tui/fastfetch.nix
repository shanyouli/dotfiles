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
  cfg = config.modules.fastfetch;
in {
  options.modules.fastfetch = {
    enable = mkEnableOption "Whether to use fastfetch";
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.fastfetch];
  };
}
