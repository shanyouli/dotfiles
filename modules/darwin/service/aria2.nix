{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.aria2;
  cft = config.modules.download.aria2;
in {
  options.modules.service.aria2 = {
    enable = mkBoolOpt cft.service.enable;
  };

  config = mkIf cfg.enable {
    launchd.user.agents.aria2 = {
      path = ["${cft.package}/bin" config.modules.service.path];
      serviceConfig = {
        ProgramArguments = [
          "${cft.package}/bin/aria2c"
          # (mkIf (config.modules.proxy.default != "") "--all-proxy=http://127.0.0.1:10801")
          "--conf-path=${config.home.configDir}/aria2/config"
          "--rpc-listen-port=${toString cft.service.port}"
        ];
        KeepAlive = true;
        RunAtLoad = cft.service.startup;
      };
    };
  };
}
