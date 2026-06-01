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
  cfp = config.modules.download;
  cfg = cfp.video;
in
{
  options.modules.download.video = {
    enable = mkBoolOpt cfp.enable;
  };
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.yt-dlp
      # pkgs.yutto # 使用 pipx 安装
      pkgs.lux
      pkgs.fav
    ]; # yutto 下载bilibili
    home.configFile."yt-dlp/config".text = ''
      # 下载默认保存目录
      --paths $HOME/Downloads/Youtube
      # 下载保存文件名
      --output %(title)s.%(id)s.%(ext)s
      # download livestreams from the start.
      --live-from-start
      # 合并后的文件格式
      --merge-output-format mp4
      # --proxy http://127.0.0.1:10801
      # 拦截所有广告
      --sponsorblock-remove all
      # 字幕格式为 srt, ass
      --sub-format srt/ass/best
      # Get English and zh 字幕
      --sub-lang en,zh-*,-live_chat
      # 字幕嵌入视频,
      # --embed-subs null
      --downloader dash,m3u8:native
      ${optionalString cfp.aria2.enable ''
        --downloader aria2c
        --downloader-args "aria2c:-x16 -s 8 -k 5M"
      ''}
    '';
    # TODO: alias
  };
}
