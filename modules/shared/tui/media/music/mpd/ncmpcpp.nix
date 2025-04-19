{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.media.music.mpd;
  cfg = cfp.ncmpcpp;
in
{
  options.modules.media.music.mpd.ncmpcpp = {
    enable = mkEnableOption "Whether to use ncmpcpp";
    config = mkOpt' types.lines "" "Extra directives added to the end of ncmpcpp's configuration file";
  };
  config = mkIf cfg.enable {
    home.packages = [ (pkgs.ncmpcpp.override { visualizerSupport = true; }) ];
    home.configFile."ncmpcpp/config".text =
      let
        ncmpcpp_dir = "${config.home.cacheDir}/ncmpcpp";
        lyrics_dir = "${my.homedir}/Music/LyricsX";
      in
      ''
        mpd_music_dir = ${config.modules.media.music.directory}
        lyrics_directory = ${lyrics_dir}
        ncmpcpp_directory = ${ncmpcpp_dir}
        mpd_port = "${toString cfp.port}"

        ${builtins.readFile "${my.dotfiles.config}/ncmpcpp/config"}

        ${cfg.config}
      '';
  };
}
