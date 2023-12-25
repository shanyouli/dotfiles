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
  log_file = "${config.my.hm.dir}/Library/Logs/deeplx.log";
in {
  options.modules.service.deeplx = {
    enable = mkEnableOption "Whether to deeplx service";
    port = mkNumOpt 1188;
  };
  config = mkIf cfg.enable {
    # my.user.packages = [pkgs.deeplx];
    launchd.user.agents.deeplx = {
      serviceConfig.ProgramArguments = ["${pkgs.deeplx}/bin/deeplx" "-p" "${toString cfg.port}"];
      path = [config.environment.systemPath];
      serviceConfig.RunAtLoad = true;
      # serviceConfig.KeepAlive.NetworkState = true;
      serviceConfig.StandardOutPath = log_file;
    };
  };
}
