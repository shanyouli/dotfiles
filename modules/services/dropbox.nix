{ config, lib, pkgs, options, ... }:
with lib;
with lib.my;
let cfg = config.modules.services.dropbox;
in {
  options.modules.services.dropbox = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # see https://nixos.wiki/wiki/Dropbo
    networking.firewall = {
      allowedTCPPorts = [ 17500 ];
      allowedUDPPorts = [ 17500 ];
    };
    user.packages = [ pkgs.dropbox-cli ];
    home.services.dropbox = {
      Unit = {
        After = (if config.modules.proxy.default != null then [
          "proxy.services"
        ] else []);
        Description = "Dropbox";
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
      Service = {
        Environment = let
          QT_PLUGIN_PATH = "/run/current-system/sw" + pkgs.qt5.qtbase.qtPluginPrefix;
          QML2_IMPORT_PATH = "/run/current-system/sw" + pkgs.qt5.qtbase.qtQmlPrefix;
        in [
          "QT_PLUGIN_PATH=${QT_PLUGIN_PATH}"
          "QML2_IMPORT_PATH=${QML2_IMPORT_PATH}"
        ];
        ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
        ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
        KillMode = "control-group"; # upstream recommends process
        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;
      };
    };
  };
}
