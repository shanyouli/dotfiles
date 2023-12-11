{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.mpd;
  cfm = config.modules;
  mpdCmd = "${config.my.hm.profileDirectory}/bin/mpd";
  mpdDir = "${config.my.hm.cacheHome}/mpd";
in {
  options.modules.macos.mpd = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    modules.mpd = let
      mpdfifo = "/private/tmp/mpd.fifo";
    in {
      enable = true;
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
    launchd.user.agents.mpd = {
      script = ''
        ${mpdCmd} --no-daemon "${config.my.hm.configHome}/mpd/mpd.conf"
      '';
      path = [config.environment.systemPath];
      serviceConfig.RunAtLoad = true;
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
        enable = cfm.mpd.ncmpcppEn;
        desc = "初始化ncmpcpp";
        text = let
          ncmpcpp_dir = "${config.my.hm.cacheHome}/ncmpcpp";
          lyrics_dir = "${config.my.hm.dir}/Music/LyricsX";
        in ''
          [[ -d ${lyrics_dir} ]] || mkdir -p ${lyrics_dir}
          [[ -d ${ncmpcpp_dir} ]] || mkdir -p ${ncmpcpp_dir}
        '';
      };
    };
  };
}
