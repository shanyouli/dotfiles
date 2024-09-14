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
  };
  config = mkIf (capp.enable && cfg.enable) {
    launchd.user.agents.qbittorrent = {
      serviceConfig = {
        RunAtLoad = capp.service.startup;
        # serviceConfig.KeepAlive.NetworkState = true;
        StandardOutPath = "${config.user.home}/Library/Logs/qbittorrent-nox.log";
        ProgramArguments = [
          "${capp.package}/bin/qbittorrent-nox"
          "--webui-port=${toString capp.service.port}"
        ];
      };
      path = [config.modules.service.path];
    };
  };
}
