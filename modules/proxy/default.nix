{ config, lib, option, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.proxy;
in {
  options.modules.proxy = {
    default = mkOption { type = with types; nullOr str; default = null ; };
    httpPort = mkOption {
      type = with types; nullOr int;
      default = if cfg.default != null
                then 7890
                else null;
    };
    socksPort = mkOption {
      type = with types; nullOr int;
      default = if cfg.default != null
                then 7891
                else null;
    };
  };

  config = mkIf (cfg.default != null) {
  nix.binaryCaches = lib.mkBefore [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  ];
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
    unsetenv = [
      "https_proxy" "http_proxy" "all_proxy" "rsync_proxy" "ftp_proxy"
    ];
    home.services.proxy = (if cfg.default == "clash" then
      let pkg = cfg.clash.pkg ;
          conf = cfg.clash.confDir;
      in {
        Unit = {
          After = [ "network.target" ];
          Description = "Clash Proxy Daemon";
        };
        Install = { WantedBy = [ "default.target" ]; };
        Service = {
          ExecStart = "${pkg.out}/bin/clash -d ${conf}";
          ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
          KillMode = "control-group";
          Restart = "on-failure";
        };
      } else if cfg.default == "v2ray" then {
    } else {});
  };
}
