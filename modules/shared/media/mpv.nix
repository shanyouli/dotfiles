{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.media.mpv;
in {
  options = with lib; {
    modules.media.mpv = {
      enable = mkEnableOption "Whether to enable mpv module ";
    };
  };

  config = with lib;
    mkIf cfg.enable (mkMerge [
      {
        user.packages = with pkgs; [mpv (mkIf pkgs.stdenvNoCC.isLinux mpvc) ffmpeg];
      }
    ]);
}
