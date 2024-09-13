{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.service.deeplx;
  cft = cfm.translate.deeplx;
  log_file = "${config.user.home}/Library/Logs/deeplx.log";
  deeplx = pkgs.unstable.deeplx;
in {
  options.modules.service.deeplx = {
    enable = mkBoolOpt cft.service.enable;
    port = mkNumOpt 1188;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.deeplx = {
      serviceConfig.ProgramArguments = ["${deeplx}/bin/deeplx" "-p" "${toString cfg.port}"];
      path = [config.modules.service.path];
      serviceConfig.RunAtLoad = cft.service.startup;
      # serviceConfig.KeepAlive.NetworkState = true;
      serviceConfig.StandardOutPath = log_file;
    };
  };
}
