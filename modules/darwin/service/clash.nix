{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.clash;
  cfgFile = "${config.my.hm.configHome}/clash-meta/clash.yaml";
  mclash = config.modules.tool.clash;
in {
  options.modules.service.clash = {
    enable = mkBoolOpt false;
    configFile = mkOpt' types.path cfgFile "clash 配置文件保存位置";
    package = mkPkgOpt pkgs.clash "clash command";
  };

  config = mkIf cfg.enable (let
    clashCmd = "${mclash.package}/bin/${mclash.package.pname}";
    workdir = "${config.my.hm.cacheHome}/clash";
    log_file = "${config.my.hm.dir}/Library/Logs/clash-meta.log";
    # 为什么需要在启动clash前设置dns，
    # @seehttps://github.com/Dreamacro/clash/issues/2615
    clashService = pkgs.writeScriptBin "clash-service" ''
      #!${pkgs.stdenv.shell}
      function setDNS() {
        # 使用 阿里云，百度云，114DNS，CNNIC DNS， 腾讯
        dns_servers=("223.5.5.5" "223.6.6.6" "114.114.114.114" \
          "114.114.115.115" "1.2.4.8" "210.2.4.8" "119.29.29.29" \
          "119.28.28.28" "101.226.4.6" "180.184.1.1")
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

      trap unsetDNS EXIT
      setDNS
      sudo ${clashCmd} -f "${cfg.configFile}" -d "${workdir}"
    '';
  in {
    user.packages = [pkgs.clash-nyanpasu-app];
    modules.tool.clash = {
      enable = true;
      package = cfg.package;
      configFile = cfg.configFile;
    };

    macos.userScript.clashUI.text = ''
      echo "init clash UI"
      [[ -d ${workdir} ]] || mkdir -p ${workdir}
      [[ -d ${workdir}/ui ]] || {
        echo "init Clash Web UI"
        git clone --depth 1 -b gh-pages https://github.com/MetaCubeX/Yacd-meta.git \
          ${workdir}/ui
      }
    '';

    launchd.user.agents.clash = {
      path = [config.environment.systemPath];
      serviceConfig.WorkingDirectory = workdir;
      serviceConfig.RunAtLoad = true;
      serviceConfig.StandardOutPath = log_file;
      serviceConfig.ProgramArguments = ["${clashService}/bin/clash-service"];
      serviceConfig.ProcessType = "Background";
    };
  });
}
