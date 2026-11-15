{
  pkgs,
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos.services;
  cfg = cfp.tmux;
  cft = config.modules.shell.tmux;
in
{
  options.modules.macos.services.tmux = {
    enable = mkBoolOpt cft.service.enable;
  };
  config = mkIf cfg.enable {
    launchd.user.agents.tmux = {
      path = [
        "${pkgs.tmux}/bin"
        config.modules.macos.services.path
      ];
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
