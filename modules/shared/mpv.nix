{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.mpv;
in {
  options = with lib; {
    my.modules.mpv = {
      enable = mkEnableOption "Whether to enable mpv module ";
    };
  };

  config = with lib;
    mkIf cfg.enable (mkMerge [
      {
        my.user.packages = with pkgs; [mpv ffmpeg];
      }
    ]);
}
