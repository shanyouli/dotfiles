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
  cfp = config.modules.media.music;
  cfg = cfp.musikcube;
in
{
  options.modules.media.music.musikcube = {
    enable = mkEnableOption "Whether to using musikcube";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.musikcube ]; };
}
