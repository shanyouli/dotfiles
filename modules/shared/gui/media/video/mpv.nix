{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.gui.media.video;
  cfg = cfp.mpv;
in {
  options.modules.gui.media.video.mpv = {
    enable = mkEnableOption "Whether to use mpv";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.mpv];
  };
  # TODO: 配置管理
}
