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
    env = with config.modules; mkMerge [
      (mkIf dev.rust.enable {
        RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup";
      })
    ];
    user.packages = [ pkgs.nmap ];

    modules.shell.zsh.rcInit =
      let httpProxy = "http://127.0.0.1:${toString cfg.httpPort}";
      in ''
        function sproxy() {
          export http_proxy="${httpProxy}"
          export https_proxy="${httpProxy}"
          export all_proxy="${httpProxy}"
          export rsync_proxy="${httpProxy}"
          export ftp_proxy="${httpProxy}"
        }

        function unproxy() {
           unset "https_proxy" "http_proxy" "all_proxy" "rsync_proxy" "ftp_proxy"
        }
      '';

    home = with config.modules; mkMerge [
      (mkIf dev.rust.enable {
        dataFile."cargo/config".source = configDir + "/cargo/config";
      })
      {
        file.".ssh/config".text = ''
          Host github.com
          HostName github.com
          User git
          Port 22
          ProxyCommand ${pkgs.nmap}/bin/ncat --proxy 127.0.0.1:${toString cfg.socksPort} --proxy-type socks5 %h %p
        '';
        services.proxy = let
          div = if ( cfg.default == "clash" && cfg.clash.enable ) then {
            exec = "${cfg.clash.pkg}/bin/clash -d ${cfg.clash.confDir}";
            desription = "Clash Proxy Daemon";
          } else if ( cfg.default == "v2ray" && cfg.v2ray.enable ) then {
            exec = "${cfg.v2ray.pkg}/bin/v2ray -confdir ${cfg.v2ray.confDir}";
            description = "V2ray Proxy Daemon";
          } else {};
        in {
          Unit = {
            After = [ "network.target" ];
            Description = "${div.description}";
          };
          Install = { WantedBy = [ "default.target" ]; };
          Service = {
            ExecStart = "${div.exec}";
            ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
            KillMode = "control-group";
            Restart = "on-failure";
          };
        };
      }
    ];
  };
}
