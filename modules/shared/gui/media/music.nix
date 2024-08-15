{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.gui.media;
  cfg = cfp.music;
in {
  options.modules.gui.media.music = {
    netease.enable = mkBoolOpt config.modules.media.music.netease.enable;
  };
  config = mkIf config.modules.gui.enable (mkMerge [
    (mkIf cfg.netease.enable {
      user.packages = [(mkIf pkgs.stdenvNoCC.isLinux pkgs.netease-cloud-music-gtk)];
    })
  ]);
}
