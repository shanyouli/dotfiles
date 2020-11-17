{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.modules.proxy.clash;
  port = if config.modules.proxy.default != null then {
    socks = "${toString config.modules.proxy.socksPort}";
    http  = "${toString config.modules.proxy.httpPort}";
  } else {
    socks = "7891";
    http  = "7890";
  };
  path = config.my.path;
in {
  options.modules.proxy.clash = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    confDir = mkOption {
      type = types.str;
      default = "${path.xdgConfig}/clash";
      description = "The directory where clash configuration from.";
    };
  };
  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 9090 ];
      allowedUDPPorts = [ 9090 ];
    };
    my = {
      packages = [ pkgs.unstable.clash ];
      home.xdg.configFile."clash/config.yaml".text =
        ''
          port:  ${toString port.http}
          socks-port: ${toString port.socks}
          ${readFile <config/clash/config.yaml>}
        '';
    };
  };
}
