{
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.services.alist;
  cft = config.modules.services.files.alist;
in
{
  options.modules.macos.services.alist = {
    enable = mkBoolOpt cft.service.enable;
  };

  config = mkIf cfg.enable {
    launchd.user.agents.alist = {
      serviceConfig.ProgramArguments = [
        "${cft.pkg}/bin/alist"
        "server"
        "--data"
        "${cft.service.workDir}"
      ];
      path = [ config.modules.macos.services.path ];
      serviceConfig.RunAtLoad = cft.service.startup;
      # serviceConfig.KeepAlive.NetworkState = true;
      # serviceConfig.StandardErrorPath = log_file;
      # serviceConfig.WorkingDirectory = workdir;
    };
  };
}
