{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.video;
in {
  options.modules.desktop.media.video = {
    enable = mkBoolOpt false;
    zyEn = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      mpv-with-scripts
      mpvc  # CLI controller for mpv
    ] ++ optional config.services.xserver.enable celluloid # nice GTK GUI for mpv
    ++ optional cfg.zyEn my.zyplayer;
    home.configFile."mpv" = {
      source = "${configDir}/mpv";
      recursive = true;
    };
  };
}
