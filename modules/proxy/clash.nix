{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.modules.proxy.clash;
  port = with config.modules.proxy;
    if default != null then {
      http = "${toString httpPort}";
      socks = "${toString socksPort}";
    } else {
      http = "7890";
      socks = "7891";
    };
in
{
  options.modules.proxy.clash = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    confDir = mkOption {
      type = types.str;
      default = "${xdgConfig}/clash";
      description = "The directory where clash configuration from.";
    };
    pkg = mkOption {
      type = types.package;
      default = pkgs.unstable.clash;
    };
  };

  config = mkIf cfg.enable {
    warnings = optional (cfg.confDir != "${xdgConfig}/clash") "
      Port configuration can not be used.
    ";
    user.packages = [ cfg.pkg ];
    networking.firewall = {
      allowedTCPPorts = [ 9090 ];
      allowedUDPPorts = [ 9090 ];
    };
    home.configFile = (if cfg.confDir == "${xdgConfig}/clash" then {
      "clash/config.yaml".text =
        let file = "${configDir}/clash/config.yaml";
        in ''
          port:  ${port.http}
          socks-port: ${port.socks}
          ${readFile file}
        '';
    } else {});
  };
}
