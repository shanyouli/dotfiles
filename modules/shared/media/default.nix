{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.media;
in {
  options.modules.media = {
    ffmpeg.pkg = mkOpt types.package pkgs.ffmpeg-full;
  };
  config = mkIf (cfg.music.enable || cfg.video.enable) {
    user.packages = [cfg.ffmpeg.pkg];
  };
}
