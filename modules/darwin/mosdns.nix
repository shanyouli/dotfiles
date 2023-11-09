{ pkgs, lib, config, options, ... }:
with lib;
with lib.my;
let cfg = config.my.modules.macos.mosdns;
in {
  options.my.modules.macos.mosdns = { enable = mkBoolOpt false; };
  config = mkIf cfg.enable {
    my.user.packages = [ pkgs.mosdns ];
    launchd.user.agents.mosdns = let
      workdir = "${config.my.hm.configHome}/mosdns";
      log_file = "${config.my.hm.dir}/Library/Logs/mosdns.log";
    in {
      script = ''
        ${pkgs.mosdns}/bin/mosdns start -d "${workdir}" -c ${workdir}/config.yaml
      '';
      path = [ config.environment.systemPath ];
      serviceConfig.RunAtLoad = true;
      # serviceConfig.KeepAlive.NetworkState = true;
      serviceConfig.StandardErrorPath = log_file;
      serviceConfig.WorkingDirectory = workdir;
    };
  };
}
