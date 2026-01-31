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
  bbdown = pkgs.writeScriptBin "bbdown" ''
    #!${pkgs.stdenv.shell}
    # 配置缓存目录
    _dir=''${XDG_CACHE_HOME:-$HOME/.cache}/bbdown
    # 目录如果不存在则创建它
    mkdir -p $_dir
    # 获取hash 值
    get_shasum() { shasum $1 | cut -d" " -f1 ; }
    # 更新执行程序
    copy_source() {
      local file1=$_dir/bbdown
      local file2=${pkgs.bbdown}/lib/BBDown/BBDown
      local hash2=$(get_shasum $file2)
      if [[ ! -f "$file1" || "$(get_shasum $file1)" != "$(get_shasum $file2)" ]]; then
         cp -rf $file2 $file1
      fi
    }
    copy_source
    which ffmpeg >/dev/null || {
      echo "ffmpeg is not installed"
      exit 1
    }
    exec -a "$0" "$_dir/bbdown"  "$@"
  '';
in
{
  options.modules.download.video = {
    enable = mkBoolOpt cfp.enable;
  };
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.yt-dlp
      # pkgs.unstable.yutto # 使用 pipx 安装
      pkgs.unstable.lux
      pkgs.unstable.fav
      bbdown
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
