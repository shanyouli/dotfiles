{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.aria2;
in {
  options.modules.macos.aria2 = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.aria2.enable = true;
    modules.aria2.aria2p = true;
    launchd.user.agents.aria2 = {
      path = ["${pkgs.aria2}/bin" config.environment.systemPath];
      script = ''
        ${pkgs.aria2}/bin/aria2c --all-proxy=http://127.0.0.1:10801  \
          --conf-path=${config.my.hm.configHome}/aria2/config
      '';
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
