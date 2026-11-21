{
  lib,
  my,
  config,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.services.herdr;
  cft = config.modules.shell.multiplexer.herdr;
in
{
  options.modules.macos.services.herdr = {
    enable = mkBoolOpt' cft.service.enable "是否通过 launchd 管理 herdr 后台服务。";
  };

  config = mkIf (cfg.enable && cft.enable) {
    launchd.user.agents.herdr = {
      path = [
        "${cft.package}/bin"
        config.home.profileBinDir
        config.modules.macos.services.path
      ];
      serviceConfig = {
        ProgramArguments = [
          "${cft.package}/bin/herdr"
          "server"
        ];
        EnvironmentVariables = {
          HOME = config.home.homeDirectory;
          HERDR_CONFIG_PATH = "${config.home.configDir}/herdr/config.toml";
          XDG_CONFIG_HOME = config.home.configDir;
        };
        WorkingDirectory = config.home.homeDirectory;
        RunAtLoad = cft.service.startup;
        StandardOutPath = "${config.home.configDir}/herdr/launchd.log";
        StandardErrorPath = "${config.home.configDir}/herdr/launchd-error.log";
      };
    };
  };
}
