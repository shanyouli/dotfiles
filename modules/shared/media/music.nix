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
  cfg = cfm.media.music;
in {
  options.modules.media.music = with types; {
    enable = mkEnableOption "Whether to music";
    musicDirectory = mkOpt' path "${config.user.home}/Music" "Music Directory";
    mpd = {
      enable = mkBoolOpt true;
      extraConfig = mkOpt' lines "" ''
        Extra directives added to the end of MPD's configuration file.
      '';
      port = mkOpt' number 6600 ''
        Listen on port
      '';

      ncmpcpp.enable = mkBoolOpt false;
      ncmpcpp.config = mkOpt' lines "" ''
        Extra directives added to the end of MPD's configuration file.
      '';
      # 使用 rust 编写的 mpd 客户端
      # see @https://mierak.github.io/rmpc/
      rmpc.enable = mkBoolOpt true;
    };
    netease.enable = mkBoolOpt true;
    netease.enGui = mkBoolOpt config.modules.opt.enGui;
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.mpd.enable {
      user.packages = with pkgs; [
        mpd
        mpc-cli
        (mkIf cfg.mpd.ncmpcpp.enable (ncmpcpp.override {visualizerSupport = true;}))
        (mkIf cfg.mpd.rmpc.enable pkgs.unstable.rmpc)
      ];
      modules.shell.aliases.mpcs = "mpc search any";
      modules.shell.aliases.mpcsp = "mpc searchplay any";
      home = let
        mpd_dir = "${config.home.cacheDir}/mpd";
        ncmpcpp_dir = "${config.home.cacheDir}/ncmpcpp";
        lyrics_dir = "${config.user.home}/Music/LyricsX";
      in
        mkMerge [
          {
            configFile."mpd/mpd.conf".text = ''
              music_directory "${cfg.musicDirectory}"
              playlist_directory "${mpd_dir}/playlists"
              db_file "${mpd_dir}/mpd.db"
              log_file "${mpd_dir}/mpd.log"
              pid_file "${mpd_dir}/mpd.pid"
              state_file "${mpd_dir}/mpdstate"
              bind_to_address "127.0.0.1"
              port "${toString cfg.mpd.port}"
              auto_update "yes"
              auto_update_depth "2"
              follow_outside_symlinks "yes"
              follow_inside_symlinks "yes"
              decoder {
                plugin "mp4ff"
                enabled "no"
              }

              # Save the macos and Linux conflict part configuration
              ${cfg.mpd.extraConfig}
            '';
          }
          (mkIf cfg.mpd.ncmpcpp.enable {
            configFile."ncmpcpp/config".text = ''
              mpd_music_dir = ${cfg.musicDirectory}
              lyrics_directory = ${lyrics_dir}
              ncmpcpp_directory = ${ncmpcpp_dir}
              mpd_port = "${toString cfg.mpd.port}"

              ${builtins.readFile "${config.dotfiles.configDir}/ncmpcpp/config"}

              ${cfg.mpd.ncmpcpp.config}
            '';
          })
        ];
    })
    (mkIf cfg.netease.enable {
      user.packages = [
        pkgs.unstable.go-musicfox
        (mkIf (pkgs.stdenvNoCC.isLinux && cfg.netease.enGui) pkgs.unstable.netease-cloud-music-gtk)
      ];
    })
  ]);
}
