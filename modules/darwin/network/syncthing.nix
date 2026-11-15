{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.syncthing;
  # launchd 的 StandardOutPath/StandardErrorPath 必须是绝对路径，
  # 因此在使用处把 ~ 展开成 config.home.homeDirectory；
  # option 本身保持与具体用户无关的写法。
  launchdLogDir = builtins.replaceStrings [ "~" ] [ config.home.homeDirectory ] cfg.logDir;
in
{
  options = {
    services.syncthing = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the Syncthing service.";
      };

      homeDir = mkOption {
        type = types.str;
        default = "~";
        example = "~";
        description = ''
          the base location for the syncthing folder
        '';
      };

      logDir = mkOption {
        type = types.str;
        default = "~/Library/Logs";
        example = "~/Library/Logs";
        description = ''
          The logfile to use for the Syncthing service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.syncthing ];
    launchd.user.agents.syncthing = {
      command = "${pkgs.syncthing}/bin/syncthing";
      serviceConfig = {
        Label = "net.syncthing.syncthing";
        KeepAlive = true;
        LowPriorityIO = true;
        ProcessType = "Background";
        StandardOutPath = "${launchdLogDir}/Syncthing.log";
        StandardErrorPath = "${launchdLogDir}/Syncthing-Errors.log";
        EnvironmentVariables = {
          NIX_PATH = "nixpkgs=" + toString pkgs.path;
          STNORESTART = "1";
        };
      };
    };
  };
}
