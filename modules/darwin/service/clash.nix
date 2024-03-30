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
  cfgFile = "${config.dotfiles.configDir}/clash-meta/clash.yaml";
  mclash = config.modules.tool.clash;
in {
  options.modules.service.clash = {
    enable = mkBoolOpt false;
    configFile = mkOpt' types.path cfgFile "clash 配置文件保存位置";
    package = mkPkgOpt pkgs.clash "clash command";
  };

  config = mkIf cfg.enable (let
    clashCmd = "${mclash.package}/bin/${mclash.package.pname}";
    workdir = "${config.home.cacheDir}/clash";
    log_file = "${config.user.home}/Library/Logs/clash-meta.log";
    # 为什么需要在启动clash前设置dns，
    # @seehttps://github.com/Dreamacro/clash/issues/2615
    clashService = pkgs.writeScriptBin "clash-service" ''
      #!${pkgs.stdenv.shell}
      function random_el_in_arr() {
          local arr=("$@")
          printf '%s' "''${arr[RANDOM % $#]}"
      }

      function _setDNS() {
          local IFS=$'\n'
          for i in $(networksetup -listallnetworkservices | tail -n +2); do
              networksetup -setdnsservers "$i" "$@"
          done
      }

      function clear_dns() {
        _setDNS 'Empty'
        if [[ -f ${log_file} ]]; then
          rm -rf ${log_file}
          touch ${log_file}
        fi
      }

      function set_dns() {
        # 使用 阿里云，百度云，114DNS，CNNIC DNS， 腾讯
          local all_dns=("223.5.5.5" "223.6.6.6" \
              "114.114.114.114" "114.114.115.115" \
              "1.2.4.8" "210.2.4.8" \
              "119.29.29.29" "119.28.28.28" \
              "101.226.4.6" "180.184.1.1")
          local dns1=$(random_el_in_arr "''${all_dns[@]}")
          local dns2=$(random_el_in_arr "''${all_dns[@]}")
          _setDNS "$dns1" "$dns2"
      }
      trap clear_dns EXIT SIGKILL SIGQUIT ERR
      set_dns
      sudo ${clashCmd} -f "${cfg.configFile}" -d "${workdir}"
    '';
  in {
    user.packages = [pkgs.stable.clash-nyanpasu-app];
    modules.tool.clash = {
      enable = true;
      package = cfg.package;
      configFile = cfg.configFile;
    };

    macos.userScript.clashUI.text = ''
      echo-info "init clash UI"
      [[ -d ${workdir} ]] || mkdir -p ${workdir}
      [[ -d ${workdir}/ui ]] || {
        echo "init Clash Web UI"
        git clone --depth 1 -b gh-pages https://github.com/MetaCubeX/Yacd-meta.git \
          ${workdir}/ui
      }
    '';

    launchd.user.agents.clash = {
      path = [config.modules.service.path];
      serviceConfig.WorkingDirectory = workdir;
      serviceConfig.RunAtLoad = true;
      serviceConfig.StandardOutPath = log_file;
      serviceConfig.ProgramArguments = ["${clashService}/bin/clash-service"];
      serviceConfig.ProcessType = "Background";
    };
  });
}
