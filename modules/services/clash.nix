{ config, options, lib, pkgs, ... }:
with lib;
let
  name = "clash";
  cfg = config.modules.services.clash;
  path = config.my.path;
in
{
  options.modules.services.clash = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    confDir = mkOption {
      type = types.str;
      default = "${path.xdgConfig}/clash";
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
      packages = [ pkgs.unstable.clash ];
      home.xdg.configFile."clash/config.yaml".source = <config/clash/config.yaml>;
      services.clash = {
        after = [ "network.target" ];
        description = "Clash Proxy Daemon";
        wantedBy = [ "default.target" ];
        # TODO: 使 my 可以在 右端使用。
        serviceConfig = {
          # Environment = "XDG_CONFIG_HOME=${xdg_config_home}";
          ExecStart = "${pkgs.unstable.clash.out}/bin/clash -d ${config.my.path.xdgConfig}/clash";
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
