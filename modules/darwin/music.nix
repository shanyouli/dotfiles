{
  lib,
  config,
  options,
  pkgs,
  ...
}: let
  cfg = config.my.modules.macos.music;
in {
  options = with lib; {
    my.modules.macos.music = {
      enable = mkEnableOption "Whether to enable music module ";
    };
  };
  config = with lib;
    mkIf cfg.enable {
      homebrew.casks = [
        # "neteasemusic" # yesplaymusic 目前使用go-musicfox取代
        "vox"
        "lx-music" # 可下载无损音乐
      ];
      # musicn 无法下载无损音乐了
      my.user.packages = [pkgs.go-musicfox pkgs.lyricx-app pkgs.musicn];
    };
}
