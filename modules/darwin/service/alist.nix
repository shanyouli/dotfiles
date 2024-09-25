{
  lib,
  my,
  config,
  options,
  ...
}:
with lib;
with my; let
  cfg = config.modules.service.alist;
  cft = config.modules.alist;
in {
  options.modules.service.alist = {
    enable = mkBoolOpt cft.service.enable;
  };

  config = mkIf cfg.enable {
    launchd.user.agents.alist = {
      serviceConfig.ProgramArguments = ["${cft.pkg}/bin/alist" "server" "--data" "${cft.service.workDir}"];
      path = [config.modules.service.path];
      serviceConfig.RunAtLoad = cft.service.startup;
      # serviceConfig.KeepAlive.NetworkState = true;
      # serviceConfig.StandardErrorPath = log_file;
      # serviceConfig.WorkingDirectory = workdir;
    };
  };
}
