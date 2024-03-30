{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.alist;
  package = pkgs.stable.alist.override {withZshCompletion = true;};
  workdir = "${config.home.cacheDir}/alist";
in {
  options.modules.service.alist = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = [package];
    modules.shell.rcInit = ''
      alist() {
          if [[ "$*" == *--data* ]]; then
              command alist "$@"
          else
              command alist "$@" --data "${workdir}"
          fi
      }
    '';
    launchd.user.agents.alist = {
      serviceConfig.ProgramArguments = ["${package}/bin/alist" "server" "--data" "${workdir}"];
      path = [config.modules.service.path];
      serviceConfig.RunAtLoad = true;
      # serviceConfig.KeepAlive.NetworkState = true;
      # serviceConfig.StandardErrorPath = log_file;
      # serviceConfig.WorkingDirectory = workdir;
    };
  };
}
