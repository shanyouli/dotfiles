{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.modules.proxy.clash;
  cfgCD = "${xdgConfig}/clash" ;
  port = with config.modules.proxy; if default == "clash" then {
    http = "${toString httpPort}";
    socks = "${toString socksPort}";
  } else {
    http = "1080";
    socks = "1081";
  };
in {
  options.modules.proxy.clash = {
    enable = mkBoolOpt false;
    confDir = mkOption {
      type = types.str;
      default = "${xdgConfig}/clash";
      description = "The directory where clash configuration from.";
    };
    pkg = mkPkgReadOpt "The clash including any override.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.proxy.clash.pkg = pkgs.unstable.v2ray;
      warnings = optional (cfg.confDir != "${cfgCD}") "
        proxy.Port configuration can not be used.
      ";
      user.packages = [ cfg.pkg ];
      networking.firewall = {
        allowedTCPPorts = [ 9090 ];
        allowedUDPPorts = [ 9090 ];
      };
    }
    (mkIf (cfg.confDir == "${cfgCD}") {
      home.configFile."clash/config.yaml".text =
        let file = "${configDir}/clash/config.yaml";
        in ''
          port:  ${port.http}
          socks-port: ${port.socks}
          ${readFile file}
        '';
    })
  ]);
}
