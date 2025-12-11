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
  cfp = config.modules.gui.media;
  cfg = cfp.music;
in
{
  options.modules.gui.media.music = {
    netease.enable = mkBoolOpt (config.modules.media.music.netease.enable && config.modules.gui.enable);
  };
  config = mkMerge [
    (mkIf cfg.netease.enable {
      home.packages = [ (mkIf pkgs.stdenvNoCC.isLinux pkgs.netease-cloud-music-gtk) ];
    })
  ];
}
