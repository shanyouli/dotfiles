{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.service.mysql;
  cft = cfm.db.mysql;
in {
  options.modules.service.mysql = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.mysql = {
      path = [config.modules.service.path];
      serviceConfig.RunAtLoad = cft.service.startup;
      serviceConfig.WorkingDirectory = "${cft.service.workdir}/data";
      serviceConfig.ProcessType = "Background";
      serviceConfig.ProgramArguments = [cft.service.cmd];
    };
  };
}
