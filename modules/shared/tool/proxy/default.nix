{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.tool.proxy;
  proxy_commands = ["sing-box" "clash"];
  proxy_url = "http://127.0.0.1:10801";
in {
  options.modules.tool.proxy = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = str:
        if builtins.elem str proxy_commands
        then str
        else "";
      description = "Default proxy command_lines";
    };
    servicePkg = mkPkgReadOpt "proxy service Packages";
    configFile = mkOpt' types.path "" ''proxy 配置文件'';
  };
  config = mkMerge [
    (mkIf (cfg.default == "clash") {
      modules.tool.proxy.clash.configFile = cfg.configFile;
      modules.tool.proxy.clash.enable = true;
    })
    (mkIf (cfg.default != "") {
      modules.shell.aliases.paria2 = optionalString config.modules.tool.aria2.enable "aria2c --all-proxy=${proxy_url}";

      modules.tool.proxy.servicePkg = pkgs.writeScriptBin "proxy-service" (''
          #!${pkgs.stdenv.shell}
        ''
        + optionalString pkgs.stdenvNoCC.isDarwin ''
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
        ''
        + optionalString (cfg.default == "clash") ''
          ${config.modules.tool.proxy.clash.serviceCmd}
        '');
    })
  ];
}
