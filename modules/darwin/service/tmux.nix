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
in {
  options.modules.services.tmux = {
    enable = mkBoolOpt config.modules.shell.tmux.enable;
    start.enable = mkBoolOpt true;
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
      serviceConfig.EnvironmentVariables.SHELL = "zsh";
      serviceConfig.RunAtLoad = true;
    };
  };
}
