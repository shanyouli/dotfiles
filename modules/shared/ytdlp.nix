{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.ytdlp;
in {
  options.my.modules.ytdlp = {
    enable = mkBoolOpt false;
    settings = with types;
      mkOption {
        type = attrsOf (oneOf [(nullOr str) path (listOf (either str path))]);
        apply = mapAttrs (n: v:
          if isList v
          then concatMapStringsSep "\n--${n} " (l: "'${toString l}'") v
          else "'${toString v}'");
        default = {};
        example = liberalExpression ''
          {
            live-form-start = null;
          }
        '';
      };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      my.user.packages = [pkgs.yt-dlp pkgs.python3.pkgs.musicdl];
      my.modules.ytdlp.settings = let
        download = "${config.my.hm.dir}/Downloads/Youtube";
      in {
        # Get English and zh 字幕
        sub-lang = "en,zh-*,-live_chat";
        # 字幕格式为 srt, ass
        sub-format = "srt/ass/best";
        # 字幕嵌入视频,
        # embed-subs = null;

        # 合并后的文件格式
        merge-output-format = "mp4";
        # 拦截所有广告
        sponsorblock-remove = "all";
        # 下载默认保存目录
        paths = download;
        # download livestreams from the start.
        live-from-start = null;
        # 下载保存文件名
        output = "%(title)s.%(id)s.%(ext)s";

        downloader = ["dash,m3u8:native"];
      };
    }
    (mkIf (cfg.settings != {}) {
      my.hm.configFile."yt-dlp.conf".text = let
        settingsLines =
          mapAttrsToList
          (n: v: (
            if v == "''"
            then "--${n}"
            else "--${n} ${v}"
          ))
          cfg.settings;
      in ''
        ${concatStringsSep "\n" settingsLines}
      '';
    })
  ]);
}
