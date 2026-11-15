{
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.services.nginx;
  cfm = config.modules;
  cfb = cfm.services.nginx;
  work_dir = cfb.workDir;
in
{
  options.modules.macos.services.nginx = {
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
