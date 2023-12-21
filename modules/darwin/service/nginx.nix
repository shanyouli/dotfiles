{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.service.nginx;
  cfm = config.modules;
  cfb = cfm.nginx;
in {
  options.modules.macos.service.nginx = {
    enable = mkBoolOpt false;
    workDir = mkStrOpt "/opt/nginx";
  };

  config = mkIf cfg.enable {
    modules.nginx = {
      enable = true;
      workDir = cfg.workDir;
    };
    macos.userScript.initNginx = {
      enable = cfg.enable;
      text = cfb.uScript;
      desc = "init nginx";
    };
    macos.systemScript.initNginx = {
      enable = cfg.enable;
      text = cfb.sScript;
      desc = "init nginx";
    };

    launchd.user.agents.nginx = {
      serviceConfig.ProgramArguments = [
        "${pkgs.nginx}/bin/nginx"
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
