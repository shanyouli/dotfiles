{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.gui.media.video;
  cfg = cfp.vlc;
in {
  options.modules.gui.media.video.vlc = {
    enable = mkEnableOption "Whether to use vlc";
  };
  config = mkIf cfg.enable {
    # home.packages = [] ++ optional pkgs.stdenvNoCC.isLinux [pkgs.vlc];
  };
}
