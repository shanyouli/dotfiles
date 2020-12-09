{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.proxy.v2ray;
    cfgCD = "${xdgConfig}/v2ray";
    port = with config.modules.proxy; if default == "v2ray" then {
      http = "${toString httpPort}";
      socks = "${toString socksPort}";
    } else {
      http = "1080";
      socks = "1081";
    };

in {
  options.modules.proxy.v2ray = {
    enable = mkBoolOpt false;
    vless = mkBoolOpt true;
    asset = mkBoolOpt true;
    confDir = mkOption {
      type = types.str;
      default = "${cfgCD}";
      description = "The file where v2ray configuration from.";
    };
    pkg = mkPkgReadOpt "The v2ray including any override.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.proxy.v2ray.pkg = if cfg.asset then (pkgs.unstable.v2ray.override {
        # see https://github.com/Loyalsoldier/v2ray-rules-dat
        assetOverrides = {
          "geoip.dat" = pkgs.fetchurl {
            url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202011282208/geoip.dat";
            sha256 = "ef0fb30d373bec6d671adaa27ef2ca758845913e3077833527b73453e06e21f6";
          };
          "geosite.dat" = pkgs.fetchurl {
            url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202011282208/geosite.dat";
            sha256 = "d458fde16b50d126fc6a913fbccd57257db790ad6301420154e197fbabb2ea77";
          };
        };
      }) else pkgs.unstable.v2ray ;
      user.packages = [ cfg.pkg ];
      warnings = optional ( cfg.confDir != "${cfgCD}" ) "
        Port configuration can not be used.
      ";
    }
    (mkIf (cfg.confDir == "${cfgCD}") {
      home.configFile."v2ray/config.json".text =
        let file = if cfg.vless == true
                   then "${configDir}/v2ray/vless"
                   else "${configDir}/v2ray/vmess";
        in ''
          {
            "log": { "loglevel": "warning" },
            "dns": { "hosts": { "dns.google": "8.8.8.8", "doh.pub": "119.29.29.29" },
              "servers": [
                "https://dns.google/dns-query",
                { "address": "https+local://223.5.5.5/dns-query",
                  "domains": [ "geosite:cn", "geosite:icloud" ],
                  "expectIPs": [ "geoip:cn" ]
                },
                { "address": "https://1.1.1.1/dns-query",
                  "domains": [ "geosite:geolocation-!cn" ]
                }
              ]
            },
            "inbounds": [
              { "protocol": "socks",
                "listen": "0.0.0.0",
                "port": ${port.socks},
                "tag": "Socks-In",
                "settings": { "ip": "127.0.0.1", "udp": true, "auth": "noauth" },
                "sniffing": {"enabled": true, "destOverride": [ "http", "tls" ] }
              },
              { "protocol": "http",
                "listen": "0.0.0.0",
                "port": ${port.http},
                "tag": "Http-In",
                "sniffing": { "enabled": true, "destOverride": [ "http", "tls" ] }
              }
            ],
            "outbounds": [
              ${readFile file},
              { "protocol": "dns", "tag": "Dns-Out" },
              { "protocol": "freedom", "tag": "Direct", "settings": { "domainStrategy": "UseIPv4" } },
              { "protocol": "blackhole","tag": "Reject","settings": { "response": { "type": "http" } } }
            ],
            "routing": {
              "domainStrategy": "IPIfNonMatch",
              "rules": [
                { "type": "field", "outboundTag": "Direct", "protocol": [ "bittorrent" ] },
                { "type": "field",
                  "outboundTag": "Dns-Out",
                  "inboundTag": [ "Socks-In", "Http-In" ],
                  "network": "udp","port": 53
                },
                { "type": "field", "outboundTag": "Reject", "domain": [ "geosite:category-ads-all" ] },
                { "type": "field", "outboundTag": "Proxy", "domain":  [ "full:www.icloud.com", "domain:icloud-content.com" ] },
                ${optionalString cfg.asset ''
                  { "type": "field", "outboundTag": "Direct", "domain": [ "geosite:apple-cn", "geosite:google-cn" ] },
                ''}
                { "type": "field", "outboundTag": "Direct", "domain": [ "geosite:tld-cn", "geosite:icloud" ] },
                { "type": "field", "outboundTag": "Proxy", "domain": [ "geosite:geolocation-!cn" ] },
                { "type": "field", "outboundTag": "Direct", "domain": [ "geosite:cn", "geosite:private" ] },
                { "type": "field", "outboundTag": "Direct", "ip": [ "geoip:cn", "geoip:private" ] },
                { "type": "field", "outboundTag": "Proxy", "network": "tcp,udp" }
              ]
            }
          }'';
    })
  ]);
}
