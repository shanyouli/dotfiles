{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.macos.clash;
  clashCmd = "${config.my.hm.profileDirectory}/bin/clash-meta";
  cfgFile = "${config.my.hm.configHome}/clash-meta/clash.yaml";
in {
  options.my.modules.macos.clash = {
    enable = mkBoolOpt false;
    configFile = mkOpt' types.path cfgFile ''
      clash 配置文件保存位置
    '';
  };

  config = mkIf cfg.enable {
    # homebrew.casks = [ "clash-for-windows" ]; # 手动安装 clash-verge 取代

    my.user.packages = [pkgs.clash-verge-app];
    my.modules.clash = {
      enable = true;
      configFile = cfg.configFile;
    };

    macos.userScript.clashUI = {
      enable = true;
      desc = "clash Web UI";
      text = ''
        if [[ ! -d ${config.my.hm.cacheHome}/clash ]]; then
          mkdir -p ${config.my.hm.cacheHome}/clash
        fi
        if [[ ! -d ${config.my.hm.cacheHome}/clash/ui ]]; then
          git clone --depth 1 -b gh-pages https://github.com/MetaCubeX/Yacd-meta.git \
            ${config.my.hm.cacheHome}/clash/ui
        fi
      '';
    };
    # environment.etc."sudoers.d/network".text =
    #   sudoNotPass config.my.username "/usr/sbin/networksetup";

    launchd.user.agents.clash = let
      log_file = "${config.my.hm.dir}/Library/Logs/clash-meta.log";
      workdir = "${config.my.hm.cacheHome}/clash";
    in {
      # 为什么需要在启动clash前设置dns，
      # @seehttps://github.com/Dreamacro/clash/issues/2615
      script = ''
         function setDNS() {
           # 使用 阿里云，百度云，114DNS，CNNIC DNS， 腾讯，红鱼
           dns_servers=("223.5.5.5" "223.6.6.6" "114.114.114.114" \
             "114.114.115.115" "1.2.4.8" "210.2.4.8" "119.29.29.29" \
             "119.28.28.28")
           # Get the number of DNS servers
           num_dns_servers=''${#dns_servers[@]}

           # Generate two random indexes
           index1=$((RANDOM%num_dns_servers))
           index2=$((RANDOM%num_dns_servers))

           # dns1, dns2
           dns1=''${dns_servers[$index1]}
           dns2=''${dns_servers[$index2]}

           old_IFS=$IFS
           IFS=$'\n'
           NETWORK_SERVICES=$(networksetup -listallnetworkservices | tail -n +2)

           for SERVICE in $NETWORK_SERVICES; do
             networksetup -setdnsservers "$SERVICE" $dns1 $dns2
           done
           IFS=$old_IFS
        }

        function unsetDNS() {
          old_IFS=$IFS
          IFS=$'\n'
          NETWORK_SERVICES=$(networksetup -listallnetworkservices | tail -n +2)
          for SERVICE in $NETWORK_SERVICES; do
            networksetup -setdnsservers "$SERVICE" Empty
          done
          IFS=$old_IFS
          if [[ -f ${log_file} ]]; then
            rm -rf ${log_file}
            touch ${log_file}
          fi
        }

        #
        trap unsetDNS EXIT
        setDNS
        sudo ${clashCmd} -f "${cfg.configFile}" -d "${workdir}"
      '';
      path = [config.environment.systemPath];
      serviceConfig.RunAtLoad = true;
      serviceConfig.StandardOutPath = log_file;
    };
  };
}
