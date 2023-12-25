{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.service.alist;
  package = pkgs.alist.override {withZshCompletion = true;};
  workdir = "${config.my.hm.cacheHome}/alist";
in {
  options.modules.macos.service.alist = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    my.user.packages = [package];
    launchd.user.agents.alist = {
      serviceConfig.ProgramArguments = [
        "${package}/bin/alist"
        "server"
        "--data"
        "${workdir}"
      ];
      path = [config.environment.systemPath];
      serviceConfig.RunAtLoad = true;
      # serviceConfig.KeepAlive.NetworkState = true;
      # serviceConfig.StandardErrorPath = log_file;
      # serviceConfig.WorkingDirectory = workdir;
    };
  };
}
