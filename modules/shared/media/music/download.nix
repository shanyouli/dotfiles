{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.media;
  cfg = cfp.music.download;
in
{
  options.modules.media.music.download = {
    enable = mkBoolOpt cfp.enable;
  };
  config = mkIf cfg.enable {
    # pkgs.python3.pkgs.musicdl # 以不可用
    # 目前没有合适的命令行下载工具
    # home.packages = [pkgs.musicn];
    my.user.extra = ''
      log debug "There is no proper dedicated music downloader available, but you can use tools like yt-dlp to download"
    '';
  };
}
