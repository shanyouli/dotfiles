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
    networking.firewall = {
      allowedTCPPorts = [ 7890 7891 9090 ];
      allowedUDPPorts = [ 7890 7891 9090 ];
    };
    my = {
      packages = with pkgs.unstable; [ clash ];
      home.xdg.configFile."clash/config.yaml".source = <config/clash/config.yaml>;
      services.clash = {
        after = [ "network.target" ];
        description = "Clash Proxy Daemon";
        wantedBy = [ "default.target" ];
        # TODO: 使 my 可以在 右端使用。
        serviceConfig = {
          #Environment = "XDG_CONFIG_HOME=${config.my.home.xdg.configHome}";
          ExecStart = "${pkgs.unstable.clash.out}/bin/clash";
          ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
          KillMode = "control-group";
          Restart = "on-failure";
          # PrivateTmp = true;
          # Nice = 10;
        };
      };
    };
  };
}
