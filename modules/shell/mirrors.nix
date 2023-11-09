{ config, lib, option, pkgs, ... }:
# proxy port: http 7890, socks5 7891, Tproxy 7892;
with lib;
with lib.my;
let cfg = config.modules.shell.mirrors;
    httpProxy = "http://127.0.0.1:7890";
in {
  options.modules.shell.mirrors = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    nix.binaryCaches = lib.mkBefore [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    networking = {
      proxy = {
        default = httpProxy;
        noProxy = "127.0.0.1,localhost,internal.domain";
      };
      firewall = {
        allowedTCPPorts = [ 7890 7891 7892 ];
        allowedUDPPorts = [ 7890 7891 7892 ];
      };
    };
    unsetenv = [
      "https_proxy" "http_proxy" "all_proxy" "rsync_proxy" "ftp_proxy"
    ];
    modules.shell.zsh.rcInit =  ''
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
    virtualisation.docker.extraOptions = ''
      --registry-mirror "https://hub-mirror.c.163.com" \
      --registry-mirror "https://mirror.baidubce.com"'';
    modules.dev.node.rcInit = ''
      registry=https://registry.npm.taobao.org
    '';

    env = with config.modules; mkMerge [
      (mkIf dev.rust.enable {
        RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup";
      })
      # go or https://athens.azurefd.net
      (mkIf dev.go.enable { GOPROXY = "https://goproxy.cn"; })
    ];

    home = with config.modules; mkMerge [
      {
        file.".ssh/config".text = ''
          Host github.com
          HostName github.com
          User git
          Port 22
          ProxyCommand ${pkgs.nmap}/bin/ncat --proxy 127.0.0.1:7891 --proxy-type socks5 %h %p
        '';
      }
      (mkIf dev.rust.enable {
        dataFile."cargo/config".source = configDir + "/cargo/config";
      })
    ];
  };
}
