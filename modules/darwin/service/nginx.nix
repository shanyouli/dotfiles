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
  cfg = config.modules.service.nginx;
  cfm = config.modules;
  cfb = cfm.nginx;
  work_dir = cfb.workDir;
in
{
  options.modules.service.nginx = {
    enable = mkBoolOpt cfb.service.enable;
  };

  config = mkIf cfg.enable {
    launchd.user.agents.nginx = {
      serviceConfig = {
        ProgramArguments = [
          "${cfb.package}/bin/nginx"
          "-p"
          work_dir
          "-e"
          "logs/error.log"
          "-c"
          "conf/nginx.conf"
          "-g"
          "daemon off;"
        ];
        WorkingDirectory = work_dir;
        RunAtLoad = true;
      };
    };
  };
}
