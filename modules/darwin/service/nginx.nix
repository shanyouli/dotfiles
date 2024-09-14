{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.nginx;
  cfm = config.modules;
  cfb = cfm.nginx;
  work_dir = cfb.workDir;
in {
  options.modules.service.nginx = {
    enable = mkBoolOpt cfb.service.enable;
  };

  config = mkIf cfg.enable {
    macos.userScript.initNginx = {
      inherit (cfg) enable;
      text = cfb.uScript;
      desc = "init nginx user settings";
    };
    macos.systemScript.initNginx = {
      inherit (cfg) enable;
      text = cfb.sScript;
      desc = "init nginx System Privilege Configuration";
    };

    launchd.user.agents.nginx = {
      serviceConfig.ProgramArguments = [
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
      serviceConfig.WorkingDirectory = work_dir;
      serviceConfig.RunAtLoad = true;
    };
  };
}
