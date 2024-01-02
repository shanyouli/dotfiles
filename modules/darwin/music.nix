{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.music;
  netease = config.modules.media.netease-music;
  mpdDir = "${config.home.cacheDir}/mpd";
  mpdfifo = "/private/tmp/mpd.fifo";
in {
  options.modules.macos.music = {
    enable = mkEnableOption "Whether to enable music module ";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [
      (mkIf (netease.enable && netease.enGui) "yesplaymusic") # or neteasemusic
      "vox"
      # "lx-music" # 可下载无损音乐,没有合适的音源
    ];
    user.packages = [pkgs.lyricx-app];

    modules.media.mpd.enable = true;
    modules.media.mpd = {
      extraConfig = ''
        audio_output {
          type "osx"
          name "CoreAudio"
          mixer_type "software"
        }
        # Visualizer
        audio_output {
          type "fifo"
          name "my_fifo"
          path "${mpdfifo}"
          format "44100:16:2"
        }
        # input
        input {
          enabled "no"
          plugin "qobuz"
        }
      '';
      ncmpcppConfig = ''
        visualizer_data_source = "${mpdfifo}"
      '';
    };
    macos.userScript = {
      mpd = {
        enable = true;
        desc = "初始化mpd";
        text = ''
          if [[ ! -d ${mpdDir} ]]; then
            mkdir -p ${mpdDir}
          fi

          if [[ ! -f ${mpdDir}/mpd.db ]]; then
            touch ${mpdDir}/mpd{.db,.log,.pid,state}
            mkdir -p ${mpdDir}/playlists
          fi
        '';
      };
      ncmpcpp = {
        enable = config.modules.media.mpd.ncmpcppEn;
        desc = "初始化ncmpcpp";
        text = let
          ncmpcpp_dir = "${config.home.cacheDir}/ncmpcpp";
          lyrics_dir = "${config.user.home}/Music/LyricsX";
        in ''
          [[ -d ${lyrics_dir} ]] || mkdir -p ${lyrics_dir}
          [[ -d ${ncmpcpp_dir} ]] || mkdir -p ${ncmpcpp_dir}
        '';
      };
    };
  };
}
