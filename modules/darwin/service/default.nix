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
  cfg = cfm.service;
  envScript = pkgs.writeScriptBin "launchdenv-service" ''
    #!${pkgs.stdenv.shell}
    ${concatStringsSep "\n" cfg.env}
  '';
in {
  options.modules.service = {
    env = with types;
      mkOption {
        type = attrsOf str;
        apply = mapAttrsToList (n: v: ''/bin/launchctl setenv ${n} "${v}"'');
        default = {};
        description = "use launchctl set environment variable";
      };
  };
  config = mkIf (cfg.env != []) {
    launchd.user.agents.env = {
      path = [config.environment.systemPath];
      serviceConfig.RunAtLoad = true;
      serviceConfig.ProgramArguments = ["${envScript}/bin/launchdenv-service"];
    };
  };
}
