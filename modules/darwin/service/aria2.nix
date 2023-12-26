{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.aria2;
in {
  options.modules.service.aria2 = {
    enable = mkBoolOpt false;
    port = mkNumOpt 6800;
  };

  config = mkIf cfg.enable {
    modules.tool.aria2.enable = true;
    modules.tool.aria2.aria2p = true;
    launchd.user.agents.aria2 = {
      path = ["${config.modules.tool.aria2.package}/bin" config.environment.systemPath];
      serviceConfig.ProgramArguments = [
        "${config.modules.tool.aria2.package}/bin/aria2c"
        (mkIf config.modules.tool.clash.enable "--all-proxy=http://127.0.0.1:10801")
        "--conf-path=${config.home.config.dotfiles.configDir}/aria2/config"
        "--rpc-listen-port=${toString cfg.port}"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
