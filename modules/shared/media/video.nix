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
    };
  };

  config = with lib;
    mkIf cfg.enable (mkMerge [
      {
        user.packages =
          [
            pkgs.mpv
            (mkIf pkgs.stdenvNoCC.isLinux pkgs.mpvc)
          ]
          ++ optionals cfg.stream.enable [
            pkgs.unstable.seam
          ];
      }
    ]);
}
