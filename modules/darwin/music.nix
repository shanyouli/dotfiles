{
  lib,
  config,
  options,
  my,
  pkgs,
  ...
}:
with lib;
with my; let
  cfg = config.modules.macos.music;
  scfg = config.modules.media.music;
  inherit (scfg) netease;
  mpdDir = "${config.home.cacheDir}/mpd";
  mpdfifo = "/private/tmp/mpd.fifo";
in {
  options.modules.macos.music = {
    enable = mkBoolOpt (scfg.default != "");
    lx.enable = mkBoolOpt false;
    apprhyme.enable = mkBoolOpt false;
    spotube.enable = mkBoolOpt false;
    fifo.enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable (mkMerge [
    {
      # neteasemusic or yesplaymusic
      # vox or foobar2000 auralplayer
      homebrew.casks =
        [
          "shanyouli/tap/lyricsx"
          # "shanyouli/tap/auralplayer" # 无法支持多项选择
          "foobar2000"
          # "notunes" # 阻止 applemusic 自启动
        ]
        ++ optionals config.modules.gui.media.music.netease.enable ["yesplaymusic"]
        ++ optionals cfg.lx.enable ["lx-music"]
        ++ optionals cfg.apprhyme.enable ["shanyouli/tap/apprhyme"]
        ++ optionals cfg.spotube.enable ["shanyouli/tap/spotube"];
      user.packages = [(mkIf (pkgs.unstable.darwinapps ? nowplaying-cli) pkgs.unstable.darwinapps.nowplaying-cli)];
    }
    (mkIf scfg.mpd.enable {
      modules.media.music.mpd = {
        config = ''
          audio_output {
            type "osx"
            name "CoreAudio"
            mixer_type "software"
            audio_buffer_size "8192"
            buffer_before_play "25%"
          }
          ${lib.optionalString cfg.fifo.enable ''
            # Visualizer
            audio_output {
              type "fifo"
              name "my_fifo"
              path "${mpdfifo}"
              format "44100:16:2"
            }
          ''}
          # input
          input {
            enabled "no"
            plugin "qobuz"
          }
        '';
        ncmpcpp.config = lib.optionalString cfg.fifo.enable ''
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
          inherit (scfg.mpd.ncmpcpp) enable;
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
