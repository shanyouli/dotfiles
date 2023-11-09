{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;

let
  inherit (pkgs) gnugpre iptables iproute;
  cfg = config.modules.services.xray;
  cfgdir = "/etc/xray";
  logScript = let
    logDir = "/var/log/xray";
    utilsBin = "${pkgs.coreutils}/bin";
  in ''
    [[ -d ${logDir} ]] || ${utilsBin}/mkdir -p ${logDir}
    ${utilsBin}/chown -R ${cfg.xrayUserName}  ${logDir}
  '';
in {
  options.modules.services.xray = {
    enable = mkBoolOpt false;
    xtls.enable = mkBoolOpt true;
    tproxy.enable = mkBoolOpt true;

    configDir = mkOpt' types.str "${cfgdir}" ''
      The dir wher xray configuration form.
    '';

    pkg = mkOpt' types.package pkgs.xray ''
      default package. Sometimes can use xray v2ray replaced,
      but cannot use XTLS configuration
    '';

    xrayUserName = mkOption {
      type = types.str;
      default = "xray";
      description = ''
        The user who would run the v2ray proxy systemd service,
        will be created automatically.
      '';
    };

    # 是否开启 log file
    logDirEnable = mkBoolOpt true;

    # 当可用 cdn 时，修改地址
    cloudIp = mkStrOpt null;
  };

  config = mkIf cfg.enable {
    users.users.${cfg.xrayUserName} = {
      description = "xray Daemon user";
      isSystemUser = true;
    };
    environment.etc = mkMerge [
      {
        "xray/00_log.json".source = "${configDir}/xray/00_log.json";
        "xray/02_dns.json".source = "${configDir}/xray/02_dns.json";
        "xray/03_routing.json".source = "${configDir}/xray/03_routing.json";
        "xray/05_inbounds.json".source = "${configDir}/xray/05_inbounds.json";
        "xray/06_outbounds.json".source =
          if cfg.xtls.enable
          then "${configDir}/secret/xtls.json"
          else if (cfg.cloudIp != null)
          then (text.substitution
            ../../config/secret/vless.json
            ''\"address\":.*,''
            ''\"address\": \"${cfg.cloudIp}\",''
          ) else "${configDir/secret/vless.json}";
      }
      (mkIf cfg.logDirEnable {
        "xray/10_logs.json".text = ''
          {
            "log": {
              "error": "/var/log/xray/error.log",
              "access": "/var/log/xray/access.log",
              "loglevel": "debug"
            }
          }
        '';
      })
    ];

    boot.kernel.sysctl = (mkIf cfg.tproxy.enable {
      "net.ipv4.ip_forward" = 1;
    });

    systemd.services.xray-transproxy = let
      ipt = "${iptables}/bin/iptables";
      ip = "${iproute}/bin/ip";
      preStartScript = pkgs.writeShellScript "xray-prestart" ''
        ${ip} route add local default dev lo table 100 # 添加路由表 100
        ${ip} rule add fwmark 1 table 100 # 为路由表 100 设定规则
        ${ipt} -t mangle -N XRAY
        # dns 国内直连

        ${ipt} -t mangle -A XRAY -d 10.0.0.0/8 -j RETURN
        ${ipt} -t mangle -A XRAY -d 100.64.0.0/10 -j RETURN
        ${ipt} -t mangle -A XRAY -d 127.0.0.0/8 -j RETURN
        ${ipt} -t mangle -A XRAY -d 169.254.0.0/16 -j RETURN
        ${ipt} -t mangle -A XRAY -d 172.16.0.0/12 -j RETURN
        ${ipt} -t mangle -A XRAY -d 172.17.0.0/16 -j RETURN
        ${ipt} -t mangle -A XRAY -s 172.17.0.0/16 -j RETURN
        ${ipt} -t mangle -A XRAY -d 192.0.0.0/24 -j RETURN
        ${ipt} -t mangle -A XRAY -d 224.0.0.0/4 -j RETURN
        ${ipt} -t mangle -A XRAY -d 240.0.0.0/4 -j RETURN
        ${ipt} -t mangle -A XRAY -d 255.255.255.255/32 -j RETURN
        ${ipt} -t mangle -A XRAY -d 192.168.0.0/16 -p tcp ! --dport 53 -j RETURN
        ${ipt} -t mangle -A XRAY -d 192.168.0.0/16 -p udp ! --dport 53 -j RETURN
        ${ipt} -t mangle -A XRAY -p tcp -j TPROXY --on-port 7892 --tproxy-mark 1
        ${ipt} -t mangle -A XRAY -p udp -j TPROXY --on-port 7892 --tproxy-mark 1
        ${ipt} -t mangle -A PREROUTING -j XRAY

        ${ipt} -t mangle -N XRAY_SELF
        ${ipt} -t mangle -A XRAY_SELF -d 10.0.0.0/8 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 100.64.0.0/10 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 127.0.0.0/8 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 169.254.0.0/16 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 172.16.0.0/12 -j RETURN

        ${ipt} -t mangle -A XRAY_SELF -d 172.17.0.0/16 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -s 172.17.0.0/16 -j RETURN

        ${ipt} -t mangle -A XRAY_SELF -d 192.0.0.0/24 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 224.0.0.0/4 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 240.0.0.0/4 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 255.255.255.255/32 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 192.168.0.0/16 -p tcp ! --dport 53 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -d 192.168.0.0/16 -p udp ! --dport 53 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -m mark --mark 2 -j RETURN
        ${ipt} -t mangle -A XRAY_SELF -p tcp -j MARK --set-mark 1
        ${ipt} -t mangle -A XRAY_SELF -p udp -j MARK --set-mark 1
        ${ipt} -t mangle -A OUTPUT -j XRAY_SELF
      '';
      postStopScript = pkgs.writeShellScript "xray-postStop" ''
        ${ip} rule del fwmark 1 table 100
        ${ip} route del local 0.0.0.0/0 dev lo table 100
        ${ipt} -t mangle -F
      '';
    in {
      description = "xray transparent proxy service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${lib.optionalString cfg.logDirEnable ''
          ${logScript}
        ''}
        exec ${cfg.pkg}/bin/xray run  -confdir ${cfg.configDir}
      '';

      # Don't start if the config file doesn't exist.
      unitConfig = { ConditionPathExists = "${cfg.configDir}"; };
      serviceConfig = (mkMerge [
        {
          Restart = "on-failure";
          User = cfg.xrayUserName;
        }
        (mkIf cfg.tproxy.enable {
          ExecStartPre =
            "+${preStartScript}"; # Use prefix `+` to run iptables as root/
          ExecStopPost = "+${postStopScript}";
          # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
          # CAP_NET_ADMIN: Listen on UDP.
          AmbientCapabilities =
            "CAP_NET_BIND_SERVICE CAP_NET_ADMIN"; # We want additional capabilities upon a unprivileged user.
        })
      ]);
    };
  };
}
