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
  cfp = config.modules.media;
  cfg = cfp.music.gtk;
in
{
  options.modules.media.music.gtk = {
    netease.enable = mkBoolOpt (
      config.modules.media.music.netease.enable && config.modules.fonts.enable
    );
  };
  config = mkMerge [
    (mkIf cfg.netease.enable {
      home.packages = [ (mkIf pkgs.stdenvNoCC.isLinux pkgs.netease-cloud-music-gtk) ];
    })
  ];
}
