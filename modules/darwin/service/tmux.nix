{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.services;
  cfg = cfp.tmux;
  cft = config.modules.tmux;
in {
  options.modules.services.tmux = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.tmux = {
      path = ["${pkgs.tmux}/bin" config.modules.service.path];
      serviceConfig.ProgramArguments = [
        "${pkgs.tmux}/bin/tmux"
        "-D"
      ];
      serviceConfig.EnvironmentVariables.TMUX_HOME = "${config.home.configDir}/tmux";
      serviceConfig.EnvironmentVariables.XDG_CONFIG_HOME = "${config.home.configDir}";
      serviceConfig.RunAtLoad = cft.service.startup;
    };
  };
}
