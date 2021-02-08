{ config, lib, pkgs, options, ... }:
with lib;
with lib.my;
let cfg = config.modules.services.dropbox;
    pkg = homePkgFun "${xdgData}/dropbox" pkgs.dropbox-cli;
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
    user.packages = [ pkg ];
    home.services.dropbox = let
      QT_PLUGIN_PATH = "/run/current-system/sw" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw" + pkgs.qt5.qtbase.qtQmlPrefix;
      dropboxHome = "${xdgData}/dropbox";
    in {
      Unit = {
        # After = (if config.modules.proxy.default != null then [
        #   "proxy.services"
        # ] else []);
        Description = "Dropbox";
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
      Service = {
        Environment = [
          "QT_PLUGIN_PATH=${QT_PLUGIN_PATH}"
          "QML2_IMPORT_PATH=${QML2_IMPORT_PATH}"
          "HOME=${dropboxHome}"
        ];
        ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
        ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
        ExecStop = "${pkg}/bin/dropbox stop";
        KillMode = "control-group"; # upstream recommends process
        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;
      };
    };
  };
}
