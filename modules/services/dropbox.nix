{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.modules.services.dropbox;
in {
  options.modules.services.dropbox = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # see https://nixos.wiki/wiki/Dropbo
    networking.firewall = {
      allowedTCPPorts = [ 17500 ];
      allowedUDPPorts = [ 17500 ];
    };
    my = {
      packages = [ pkgs.dropbox-cli ];
      services.dropbox = {
        description = "Dropbox";
        wantedBy = [ "graphical-session.target" ];
        environment = {
          QT_PLUGIN_PATH = "/run/current-system/sw" + pkgs.qt5.qtbase.qtPluginPrefix;
          QML2_IMPORT_PATH = "/run/current-system/sw" + pkgs.qt5.qtbase.qtQmlPrefix;
        };
        serviceConfig = {
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
  };
}
