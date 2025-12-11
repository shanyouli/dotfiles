{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.gui.media.video;
  cfg = cfp.mpv;
in
{
  options.modules.gui.media.video.mpv = {
    enable = mkEnableOption "Whether to use mpv";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.mpv ];
    # https://github.com/dyphire/mpv-config/issues/65
    home.configFile = {
      "mpv" = {
        source = "${my.dotfiles.config}/mpv";
        recursive = true;
      };
      "mpv/files/.keep".source = builtins.toFile "keep" "";
      "mpv/cache/.keep".source = builtins.toFile "keep" "";
    };
  };
}
