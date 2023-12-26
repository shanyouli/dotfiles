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
  cfg = cfm.media.netease-music;
in {
  options.modules.media.netease-music = {
    enable = mkEnableOption "Whether or not you use the NetEase Cloud Music app";
    enGui = mkBoolOpt config.modules.enGui;
  };
  config = mkIf cfg.enable {
    user.packages = [
      pkgs.go-musicfox
      (mkIf (pkgs.stdenvNoCC.isLinux && cfg.enGui) pkgs.netease-cloud-music-gtk)
    ];
  };
}
