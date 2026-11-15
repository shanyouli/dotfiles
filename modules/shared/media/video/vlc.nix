{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.media.video;
  cfg = cfp.vlc;
in
{
  options.modules.media.video.vlc = {
    enable = mkEnableOption "Whether to use vlc";
  };
  config = mkIf cfg.enable {
    # home.packages = [] ++ optional pkgs.stdenvNoCC.isLinux [pkgs.vlc];
  };
}
