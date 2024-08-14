{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.tui.media.music.mpd;
  cfg = cfp.ncmpcpp;
in {
  options.modules.tui.media.music.mpd.ncmpcpp = {
    enable = mkEnableOption "Whether to use ncmpcpp";
    config = mkOpt' types.lines "" "Extra directives added to the end of ncmpcpp's configuration file";
  };
  config = mkIf cfg.enable {
    user.packages = [(pkgs.ncmpcpp.override {visualizerSupport = true;})];
    home.configFile."ncmpcpp/config".text = let
      ncmpcpp_dir = "${config.home.cacheDir}/ncmpcpp";
      lyrics_dir = "${config.user.home}/Music/LyricsX";
    in ''
      mpd_music_dir = ${config.modules.tui.media.music.directory}
      lyrics_directory = ${lyrics_dir}
      ncmpcpp_directory = ${ncmpcpp_dir}
      mpd_port = "${toString cfp.port}"

      ${builtins.readFile "${config.dotfiles.configDir}/ncmpcpp/config"}

      ${cfg.config}
    '';
  };
}
