{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.media.video;
in {
  options = with lib; {
    modules.media.video = {
      enable = mkEnableOption "Whether to enable mpv module ";
      stream.enable = mkBoolOpt true;
      mpvc.enable = mkBoolOpt true;
    };
  };

  config = with lib;
    mkIf cfg.enable (mkMerge [
      {
        user.packages =
          [
            pkgs.mpv
          ]
          ++ optionals cfg.mpvc.enable [
            pkgs.unstable.mpvc
            pkgs.fzf
            pkgs.gawk
            pkgs.gnused
            pkgs.socat
            pkgs.rlwrap
            pkgs.jq
            (mkIf (! config.modules.media.download.enVideo) pkgs.yt-dlp)
            pkgs.util-linux
          ]
          ++ optionals cfg.stream.enable [
            pkgs.unstable.seam
          ];
      }
    ]);
}
