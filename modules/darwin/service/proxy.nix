{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.proxy;
  cft = config.modules.tool.proxy;
in {
  options.modules.service.proxy = {
    enable = mkBoolOpt (cft.default != "");
  };

  config = mkIf cfg.enable (let
    workdir = "${config.home.cacheDir}/clash";
    log_file = "${config.user.home}/Library/Logs/clash-meta.log";
  in {
    user.packages = [pkgs.unstable.darwinapps.clash-nyanpasu];
    launchd.user.agents.proxy = {
      path = [config.modules.service.path];
      serviceConfig.WorkingDirectory = workdir;
      serviceConfig.RunAtLoad = true;
      serviceConfig.StandardOutPath = log_file;

      serviceConfig.ProgramArguments = ["${cft.servicePkg}/bin/proxy-service"];
      serviceConfig.ProcessType = "Background";
    };
  });
}
