{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.macos.service.deeplx;
  log_file = "${config.my.hm.dir}/Library/Logs/deeplx.log";
  deeplxService = pkgs.writeScriptBin "deeplx-service" ''
    #!${pkgs.stdenv.shell}

    [[ -d "${cfg.workdir}" ]] || mkdir -p "${cfg.workdir}"
    [[ -f "${log_file}" ]] || touch "${log_file}"
    ${pkgs.deeplx}/bin/deeplx -p ${toString cfg.port}
  '';
in {
  options.modules.macos.service.deeplx = {
    enable = mkEnableOption "Whether to deeplx service";
    workdir = mkOpt' types.path "${config.my.hm.cacheHome}/deeplx" "deeplx workdir";
    port = mkNumOpt 1188;
  };
  config = mkIf cfg.enable {
    # my.user.packages = [pkgs.deeplx];
    launchd.user.agents.deeplx = {
      serviceConfig.ProgramArguments = ["${deeplxService}/bin/deeplx-service"];
      path = [config.environment.systemPath];
      serviceConfig.RunAtLoad = true;
      # serviceConfig.KeepAlive.NetworkState = true;
      # serviceConfig.StandardErrorPath = log_file;
      serviceConfig.StandardOutPath = log_file;
      serviceConfig.WorkingDirectory = cfg.workdir;
    };
  };
}
