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
  cfp = config.modules.media.music;
  cfg = cfp.kew;
in
{
  options.modules.media.music.kew = {
    enable = mkEnableOption "Whether to using kew.";
    package = mkPackageOption pkgs "kew" { };
  };
  config = mkIf cfg.enable { home.packages = [ cfg.package ]; };
}
