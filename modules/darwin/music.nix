{
  lib,
  config,
  options,
  pkgs,
  ...
}: let
  cfg = config.modules.macos.music;
  netease = config.modules.media.netease-music;
in {
  options = with lib; {
    modules.macos.music = {
      enable = mkEnableOption "Whether to enable music module ";
    };
  };
  config = with lib;
    mkIf cfg.enable {
      modules.media.mpd.enable = true;
      homebrew.casks = [
        (mkIf (netease.enable && netease.enGui) "yesplaymusic") # or neteasemusic
        "vox"
        "lx-music" # 可下载无损音乐
      ];
      my.user.packages = [pkgs.lyricx-app];
    };
}
