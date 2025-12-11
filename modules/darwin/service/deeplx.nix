{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.service.deeplx;
  cft = cfm.translate.deeplx;
  log_file = "${my.homedir}/Library/Logs/deeplx.log";
  inherit (pkgs.unstable) deeplx;
in
{
  options.modules.service.deeplx = {
    enable = mkBoolOpt cft.service.enable;
    port = mkNumOpt 1188;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.deeplx = {
      serviceConfig = {
        ProgramArguments = [
          "${deeplx}/bin/deeplx"
          "-p"
          "${toString cfg.port}"
        ];
        RunAtLoad = cft.service.startup;
        # serviceConfig.KeepAlive.NetworkState = true;
        StandardOutPath = log_file;
      };
      path = [ config.modules.service.path ];
    };
  };
}
