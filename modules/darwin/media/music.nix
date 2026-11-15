{
  lib,
  config,
  my,
  pkgs,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.media.music;
  scfg = config.modules.media.music;
  mpdDir = "${config.home.cacheDir}/mpd";
  mpdfifo = "/private/tmp/mpd.fifo";
in
{
  options.modules.macos.media.music = {
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
      homebrew.casks = [
        "shanyouli/tap/lyricsx"
        # "shanyouli/tap/auralplayer" # 无法支持多项选择
        # "foobar2000"
        # "shanyouli/tap/museeks"
        "shanyouli/tap/petrichor"
        # "notunes" # 阻止 applemusic 自启动
      ]
      ++ optionals config.modules.media.music.gtk.netease.enable [ "yesplaymusic" ]
      ++ optionals cfg.lx.enable [ "lx-music" ]
      ++ optionals cfg.apprhyme.enable [ "shanyouli/tap/apprhyme" ]
      ++ optionals cfg.spotube.enable [ "shanyouli/tap/spotube" ];
      user.packages = [ (mkIf (pkgs.darwinapps ? nowplaying-cli) pkgs.darwinapps.nowplaying-cli) ];
    }
    (mkIf config.modules.services.media.mpd.enable {
      modules.services.media.mpd.config = ''
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
      modules.media.music.ncmpcpp.config = lib.optionalString cfg.fifo.enable ''
        visualizer_data_source = "${mpdfifo}"
      '';
      my.user.init = {
        mpd = {
          desc = "初始化 mpd 配置。";
          text = ''
            let mpd_dir = "${mpdDir}"
            log debug $"init ($mpd_dir)"
            if (not ($mpd_dir | path exists )) {
              mkdir $mpd_dir
            }
            for i in ["db", "log", "pid", "state"] {
              let _file = $mpd_dir | path join $"mpd.($i)"
              if (not ($_file | path exists)) {
                touch $_file
              }
            }
            let _playlist = $mpd_dir | path join "playlists"
            if (not ($_playlist | path exists)) {
              mkdir $_playlist
            }
          '';
        };
        ncmpcpp = {
          desc = "初始化 ncmpcpp";
          inherit (scfg.ncmpcpp) enable;
          text = ''
            let ncmpcpp_dir = "${config.home.cacheDir}" | path join "ncmpcpp"
            let lyrics_dir = "${config.home.homeDirectory}" | path join "Music" "LyricsX"
            if (not ($ncmpcpp_dir | path exists)) {
              mkdir $ncmpcpp_dir
            }
            if (not ($lyrics_dir | path exists)) {
              mkdir $lyrics_dir
            }
          '';
        };
      };
    })
  ]);
}
