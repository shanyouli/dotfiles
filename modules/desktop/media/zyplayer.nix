{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.media.zyplayer;
in {
  options.modules.desktop.media.zyplayer = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    user.packages = [ pkgs.my.zyplayer ];
  };
}
