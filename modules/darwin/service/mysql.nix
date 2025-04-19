{
  lib,
  my,
  config,
  options,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.service.mysql;
  cft = cfm.db.mysql;
in
{
  options.modules.service.mysql = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.mysql = {
      path = [ config.modules.service.path ];
      serviceConfig = {
        RunAtLoad = cft.service.startup;
        WorkingDirectory = "${cft.service.workdir}/data";
        ProcessType = "Background";
        ProgramArguments = [ cft.service.cmd ];
      };
    };
  };
}
