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
        user.packages = with pkgs; [
          stable.mpv
          (mkIf pkgs.stdenvNoCC.isLinux stable.mpvc)
          (mkIf cfg.stream.enable unstable.seam)
        ];
      }
    ]);
}
