{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.media.mpd;
in {
  options.modules.media.mpd = with types; {
    enable = mkBoolOpt false;
    extraConfig = mkOpt' lines "" ''
      Extra directives added to the end of MPD's configuration file.
    '';
    port = mkOpt' number 6600 ''
      Listen on port
    '';
    musicDirectory = mkOpt' path "${config.user.home}/Music" "MPD read music file";

    ncmpcppEn = mkBoolOpt true;
    ncmpcppConfig = mkOpt' lines "" ''
      Extra directives added to the end of MPD's configuration file.
    '';
  };
  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = [pkgs.mpd pkgs.mpc-cli];
      modules.shell.aliases.mpcs = "mpc search any";
      modules.shell.aliases.mpcsp = "mpc searchplay any";
      home = let
        mpd_dir = "${config.home.cacheDir}/mpd";
      in {
        configFile."mpd/mpd.conf".text = ''
          music_directory "${cfg.musicDirectory}"
          playlist_directory "${mpd_dir}/playlists"
          db_file "${mpd_dir}/mpd.db"
          log_file "${mpd_dir}/mpd.log"
          pid_file "${mpd_dir}/mpd.pid"
          state_file "${mpd_dir}/mpdstate"
          bind_to_address "127.0.0.1"
          port "${toString cfg.port}"
          auto_update "yes"
          auto_update_depth "2"
          follow_outside_symlinks "yes"
          follow_inside_symlinks "yes"
          decoder {
            plugin "mp4ff"
            enabled "no"
          }

          # Save the macos and Linux conflict part configuration
          ${cfg.extraConfig}
        '';
      };
    }
    (mkIf cfg.ncmpcppEn {
      user.packages = [(pkgs.ncmpcpp.override {visualizerSupport = true;})];
      home = let
        ncmpcpp_dir = "${config.home.cacheDir}/ncmpcpp";
        lyrics_dir = "${config.user.home}/Music/LyricsX";
      in {
        configFile."ncmpcpp/config".text = ''
          mpd_music_dir = ${cfg.musicDirectory}
          lyrics_directory = ${lyrics_dir}
          ncmpcpp_directory = ${ncmpcpp_dir}
          mpd_port = "${toString cfg.port}"

          ${builtins.readFile "${config.dotfiles.configDir}/ncmpcpp/config"}

          ${cfg.ncmpcppConfig}
        '';
      };
    })
  ]);
}
