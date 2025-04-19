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
  cfg = cfp.netease;
in
{
  options.modules.media.music.netease = {
    enable = mkEnableOption "Whether to use netease music";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.unstable.go-musicfox ]; };
}
