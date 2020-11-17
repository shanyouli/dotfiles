{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.modules.proxy ;
in {
  imports = [
    ./clash.nix
  ];

  options.modules.proxy = {
    default = mkOption { type = with types; nullOr str; default = null; };
    socksPort = mkOption {
      type = with types; nullOr int;
      default = if cfg.default  != null
                then 7891
                else null;
    };
    httpPort = mkOption {
      type = with types; nullOr int;
      default  = if cfg.default  != null
                 then 7890
                 else null;
    };
  };
  config = mkIf (cfg.default  != null) {
    networking = {
      proxy = {
        default = "http://127.0.0.1:${toString cfg.httpPort}";
        noProxy = "127.0.0.1,localhost,internal.domain";
      };
      firewall = {
        allowedTCPPorts = [ cfg.httpPort cfg.socksPort ];
        allowedUDPPorts = [ cfg.httpPort cfg.socksPort ];
      };
    };
    my = {
      unset = [
        "https_proxy" "http_proxy" "all_proxy" "rsync_proxy" "ftp_proxy"
      ];
      services.proxy = {
        after = [ "network.target" ];
        description = "Clash Proxy Daemon";
        wantedBy = [ "default.target" ];
        # NOTE: 使 my 可以在 右端使用。
        serviceConfig = {
          # Environment = "XDG_CONFIG_HOME=${xdg_config_home}";
          ExecStart = "${pkgs.unstable.clash.out}/bin/clash -d ${cfg.clash.confDir}";
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
