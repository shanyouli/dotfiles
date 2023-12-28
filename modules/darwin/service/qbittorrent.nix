{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.service.qbittorrent;
in {
  options.modules.service.qbittorrent = {
    enable = mkEnableOption "Whether to use qbittorrent server";
    port = mkNumOpt 6801;
  };
  config = mkIf cfg.enable {
    modules.tool.qbittorrent.enable = true;
    modules.tool.qbittorrent.enGui = false;
    launchd.user.agents.qbittorrent = {
      serviceConfig.ProgramArguments = [
        "${cfm.tool.qbittorrent.package}/bin/qbittorrent-nox"
        "--webui-port=${toString cfg.port}"
      ];
      path = [config.modules.service.path];
      serviceConfig.RunAtLoad = true;
      # serviceConfig.KeepAlive.NetworkState = true;
      serviceConfig.StandardOutPath = "${config.user.home}/Library/Logs/qbittorrent-nox.log";
    };
  };
}
