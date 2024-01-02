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
  cfb = cfm.tool.nginx;
in {
  options.modules.service.nginx = {
    enable = mkBoolOpt false;
    workDir = mkStrOpt "/opt/nginx";
  };

  config = mkIf cfg.enable {
    modules.tool.nginx = {
      enable = true;
      workDir = cfg.workDir;
    };
    macos.userScript.initNginx = {
      enable = cfg.enable;
      text = cfb.uScript;
      desc = "init nginx user settings";
    };
    macos.systemScript.initNginx = {
      enable = cfg.enable;
      text = cfb.sScript;
      desc = "init nginx System Privilege Configuration";
    };

    launchd.user.agents.nginx = {
      serviceConfig.ProgramArguments = [
        "${cfb.package}/bin/nginx"
        "-p"
        cfg.workDir
        "-e"
        "logs/error.log"
        "-c"
        "conf/nginx.conf"
        "-g"
        "daemon off;"
      ];
      serviceConfig.WorkingDirectory = cfg.workDir;
      serviceConfig.RunAtLoad = true;
    };
  };
}
