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
  cfm = config.modules;
  cfg = cfm.service;
  envScript = pkgs.writeScriptBin "launchdenv-service" ''
    #!${pkgs.stdenv.shell}
    ${concatStringsSep "\n" cfg.env}
  '';
in
{
  options.modules.service = {
    env =
      with types;
      mkOption {
        type = attrsOf str;
        apply = mapAttrsToList (n: v: ''/bin/launchctl setenv ${n} "${v}"'');
        default = { };
        description = "use launchctl set environment variable";
      };
    path = mkStrOpt "";
  };
  config = mkMerge [
    {
      modules.service.path =
        builtins.replaceStrings [ "$USER" "$HOME" ] [ config.user.name my.homedir ]
          config.environment.systemPath;
    }
    (mkIf (cfg.env != [ ]) {
      launchd.user.agents.env = {
        path = [ cfg.path ];
        serviceConfig.RunAtLoad = true;
        serviceConfig.ProgramArguments = [ "${envScript}/bin/launchdenv-service" ];
      };
    })
    (mkIf config.modules.gpg.enable {
      programs.gnupg.agent.enable = true;
      launchd.user.agents.gnupg-agent.serviceConfig.EnvironmentVariables.GPUPGHOME = config.env.GNUPGHOME;
    })
  ];
}
