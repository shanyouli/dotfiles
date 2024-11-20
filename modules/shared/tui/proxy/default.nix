{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfm = config.modules;
  cfg = cfm.proxy;
  proxy_commands = ["sing-box" "clash"];
  proxy_url = "http://127.0.0.1:10801";
in {
  options.modules.proxy = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = str:
        if builtins.elem str proxy_commands
        then str
        else "";
      description = "Default proxy command_lines";
    };
    service = {
      pkg = mkPkgReadOpt "proxy service Packages";
      enable = mkOpt' types.bool (cfg.default != "") "为 proxy 配置服务";
      startup = mkOpt' types.bool true "开机启动 proxy置服务";
      cmd = mkOpt' types.str "" "默认proxy 启动命令，一般不需要自定义";
    };

    configFile = mkOpt' types.str "" ''proxy 配置文件'';
  };
  config = mkIf (cfg.default != "") {
    modules = {
      shell.aliases.paria2 = optionalString config.modules.download.aria2.enable "aria2c --all-proxy=${proxy_url}";
      proxy = {
        clash.enable = mkDefault (cfg.default == "clash");
        sing-box.enable = mkDefault (cfg.default == "sing-box");

        service.pkg = pkgs.writeScriptBin "proxy-service" (''
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
          + ''
            ${cfg.service.cmd}
          '');
      };
      nginx.config =
        if cfg.service.enable
        then ''
          location /proxy {
            client_max_body_size 0;
            proxy_redirect off;
            proxy_pass http://127.0.0.1:9090/ui/;
          }
        ''
        else "";
    };
  };
}
