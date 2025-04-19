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
  cfg = cfp.cmus;
in
{
  options.modules.media.music.cmus = {
    enable = mkEnableOption "Whether to use cmus";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.cmus ]; };
}
