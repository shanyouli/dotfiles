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
  scfg = config.modules.media.music;
  netease = scfg.netease;
  mpdDir = "${config.home.cacheDir}/mpd";
  mpdfifo = "/private/tmp/mpd.fifo";
in {
  options.modules.macos.music = {
    enable = mkBoolOpt scfg.enable;
  };
  config = mkIf cfg.enable (mkMerge [
    {
      homebrew.casks = ["vox"] ++ lib.optionals (netease.enable && netease.enGui) ["neteasemusic"];
      user.packages = [pkgs.lyricx-app];
    }
    (mkIf scfg.mpd.enable {
      modules.media.music.mpd = {
        extraConfig = ''
          audio_output {
            type "osx"
            name "CoreAudio"
            mixer_type "software"
            audio_buffer_size "8192"
            buffer_before_play "25%"
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
    })
  ]);
}
