{
  pkgs,
  lib,
  my,
  config,
  options,
  ...
}:
with lib;
with my; let
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
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.tmux}/bin/tmux"
          "-D"
        ];
        EnvironmentVariables = {
          TMUX_HOME = "${config.home.configDir}/tmux";
          XDG_CONFIG_HOME = "${config.home.configDir}";
        };
        RunAtLoad = cft.service.startup;
      };
    };
  };
}
