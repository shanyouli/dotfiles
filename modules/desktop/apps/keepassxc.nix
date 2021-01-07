{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.apps.keepassxc;
in {
  options.modules.desktop.apps.keepassxc = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    user.packages = [ pkgs.unstable.keepassx-community ];

    modules.desktop.browsers.firefox.extensions = [ pkgs.firefox-addons.keePassXC-Browser ];
  };
}
