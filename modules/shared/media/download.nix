{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.media.download;
in {
  options.modules.media.download = {
    enable = mkEnableOption "Whether to download media";
    enAudio = mkBoolOpt true;
    enVideo = mkBoolOpt true;
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enAudio {
      user.packages = [pkgs.musicn pkgs.python3.pkgs.musicdl];
    })
    (mkIf cfg.enVideo {
      user.packages = [pkgs.unstable.yt-dlp pkgs.yutto]; # yutto 下载bilibili
      my.hm.configFile."yt-dlp/config".text = ''
        # 下载默认保存目录
        --paths $HOME/Downloads/Youtube
        # 下载保存文件名
        --output %(title)s.%(id)s.%(ext)s
        # download livestreams from the start.
        --live-from-start
        # 合并后的文件格式
        --merge-output-format mp4
        --proxy http://127.0.0.1:10801
        # 拦截所有广告
        --sponsorblock-remove all
        # 字幕格式为 srt, ass
        --sub-format srt/ass/best
        # Get English and zh 字幕
        --sub-lang en,zh-*,-live_chat
        # 字幕嵌入视频,
        # --embed-subs null
        --downloader dash,m3u8:native
        ${optionalString cfm.tool.aria2.enable ''
          --downloader aria2c
          --downloader-args "aria2c:-x16 -s 8 -k 5M"
        ''}
      '';
      # TODO: alias
    })
  ]);
}
