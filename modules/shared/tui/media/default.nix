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
  cfp = config.modules;
  cfg = cfp.media;
in
{
  options.modules.media = {
    enable = mkEnableOption "Whether to use media tools";
    ffmpeg.pkg = mkOpt types.package pkgs.ffmpeg-full;
    stream.enable = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.ffmpeg.pkg ] ++ optionals cfg.stream.enable [ pkgs.seam ];
    # ++ optional (pkgs.stdenvNoCC.isLinux && config.modules.gui.media.video.mpv.enable) [pkgs.mpvc];
  };
}
