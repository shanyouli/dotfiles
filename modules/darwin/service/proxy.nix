{
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.service.proxy;
  cft = config.modules.proxy;
in
{
  options.modules.service.proxy = {
    enable = mkBoolOpt cft.service.enable;
  };

  config = mkIf cfg.enable (
    let
      log_file = "${my.homedir}/Library/Logs/org.nixos.proxy.log";
    in
    {
      launchd.user.agents.proxy = {
        path = [ config.modules.service.path ];
        serviceConfig = {
          RunAtLoad = cft.service.startup;
          StandardOutPath = log_file;
          ProgramArguments = [ "${cft.service.pkg}/bin/${cft.service.pkg.name}" ];
          ProcessType = "Background";
        };
      };
    }
  );
}
