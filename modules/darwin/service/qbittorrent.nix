{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  capp = cfm.app.qbittorrent;
  cfg = cfm.service.qbittorrent;
in {
  options.modules.service.qbittorrent = {
    enable = mkBoolOpt capp.service.enable;
    port = mkNumOpt 6801;
  };
  config = mkIf (capp.enable && cfg.enable) {
    launchd.user.agents.qbittorrent = {
      serviceConfig.ProgramArguments = [
        "${capp.package}/bin/qbittorrent-nox"
        "--webui-port=${toString cfg.port}"
      ];
      path = [config.modules.service.path];
      serviceConfig.RunAtLoad = capp.services.startup;
      # serviceConfig.KeepAlive.NetworkState = true;
      serviceConfig.StandardOutPath = "${config.user.home}/Library/Logs/qbittorrent-nox.log";
    };
  };
}
