{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.proxy.v2ray;
in {
  options.modules.proxy.v2ray = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages =
      [ (pkgs.unstable.v2ray.override {
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
        })
      ];
  };
}
