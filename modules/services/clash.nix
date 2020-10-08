{ config, options, lib, pkgs, ... }:
with lib;
let
  name = "clash";
  cfg = config.modules.services.clash;
in
{
  options.modules.services.clash = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    confDir = mkOption {
      type = types.str;
      default = "$XDG_CONFIG_HOME/${name}";
      defaultText = "$XDG_CONFIG_HOME/clash";
      apply = toString;
      description = ''
        The directory where clash configuration from.
      '';
    };
  };

  config = mkIf cfg.enable {
    my = {
      packages = with pkgs.unstable; [ clash ];
      home.xdg.configFile."clash" = {
        source = <config/clash>;
        recursive = true;
      };
      home.systemd.user.services.clash = {
        Unit = {
          After = [ "network.target" ];
          Description = "Clash Proxy Daemon";
        };
        Install = { WantedBy = [ "default.target" ]; };
          # TODO: 使 my 可以在 右端使用。
        Service = {
          #Environment = "XDG_CONFIG_HOME=${config.my.home.xdg.configHome}";
          ExecStart = "${pkgs.unstable.clash}/bin/clash";

#-d ${cfg.confDir}";
#${config.modules.services.clash.confDir}";
          #Restart = ""
        };
      };
    };
  };
}
