{ pkgs, lib, config, options, ... }:
with lib;
with lib.my;
let cfg = config.my.modules.macos.alist;
in {
  options.my.modules.macos.alist = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    my.user.packages = [ pkgs.alist ];
    launchd.user.agents.alist =
      let workdir = "${config.my.hm.cacheHome}/alist";
          log_file = "${config.my.hm.dir}/Library/Logs/alist.log";
      in {
        script = ''
          if [[ ! -d ${workdir} ]]; then
            mkdir -p ${workdir}
          fi
          ${pkgs.alist}/bin/alist server
        '';
        path = [ config.environment.systemPath ];
        serviceConfig.RunAtLoad = true;
        # serviceConfig.KeepAlive.NetworkState = true;
        serviceConfig.StandardErrorPath = log_file;
        serviceConfig.WorkingDirectory = workdir;
      };
  };
}
