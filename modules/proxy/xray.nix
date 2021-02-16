{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let
  inherit (pkgs) gnugpre iptables iproute;
  cfg = config.modules.proxy.xray;
  cfgdir = "/etc/xray-config";
in {
  options.modules.proxy.xray = {
    enable = mkBoolOpt false;
    vless.enable = mkBoolOpt true;
    configDir = mkOpt' types.str "${cfgdir}" ''
      The dir wher xray configuration form.
    '';
    pkg = mkOpt' types.package pkgs.xray "default package.";
    xrayUserName = mkOption {
      type = types.str;
      default = "xray";
      description = ''
        The user who would run the v2ray proxy systemd service,
        will be created automatically.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.xrayUserName} = {
      description = "xray Daemon user";
      isSystemUser = true;
    };
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    systemd.services.xray-transproxy = let
      ipt = "${iptables}/bin/iptables";
      ip = "${iproute}/bin/ip";
      preStartScript = pkgs.writeShellScript "xray-prestart" ''
        [[ -d /var/log/xray ]] || ${pkgs.coreutils}/bin/mkdir -p /var/log/xray
        for file in "error.log" "access.log"; do
          [[ -f $file ]] && ${pkgs.coreutils}/bin/touch $file
        done
        ${pkgs.coreutils}/bin/chown -R ${cfg.xrayUserName} /var/log/xray
        ${ip} route add local default dev lo table 100 # 添加路由表 100
        ${ip} rule add fwmark 1 table 100 # 为路由表 100 设定规则
        ${ipt} -t mangle -N XRAY
        ${ipt} -t mangle -A XRAY -d 10.0.0.0/8 -j RETURN
        ${ipt} -t mangle -A XRAY -d 100.64.0.0/10 -j RETURN
        ${ipt} -t mangle -A XRAY -d 127.0.0.0/8 -j RETURN
        ${ipt} -t mangle -A XRAY -d 169.254.0.0/16 -j RETURN
        ${ipt} -t mangle -A XRAY -d 172.16.0.0/12 -j RETURN
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
      script =
        "exec ${cfg.pkg}/bin/xray run  -confdir ${cfg.configDir}";

      # Don't start if the config file doesn't exist.
      unitConfig = { ConditionPathExists = "${cfg.configDir}"; };
      serviceConfig = {
        ExecStartPre =
          "+${preStartScript}"; # Use prefix `+` to run iptables as root/
        ExecStopPost = "+${postStopScript}";
        # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
        # CAP_NET_ADMIN: Listen on UDP.
        AmbientCapabilities =
          "CAP_NET_BIND_SERVICE CAP_NET_ADMIN"; # We want additional capabilities upon a unprivileged user.
        User = cfg.xrayUserName;
        Restart = "on-failure";
      };
    };
  };
}
