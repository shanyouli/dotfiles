{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.apps.calibre;
in {
  options.modules.desktop.apps.calibre = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = [ pkgs.calibre ];
  };
}
