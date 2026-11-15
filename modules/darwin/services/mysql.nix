{
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.macos.services.mysql;
  cft = cfm.services.db.mysql;
in
{
  options.modules.macos.services.mysql = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.mysql = {
      path = [ config.modules.macos.services.path ];
      serviceConfig = {
        RunAtLoad = cft.service.startup;
        WorkingDirectory = "${cft.service.workdir}/data";
        ProcessType = "Background";
        ProgramArguments = [ cft.service.cmd ];
      };
    };
  };
}
