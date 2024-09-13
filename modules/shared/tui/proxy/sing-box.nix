{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  # TODO: 设置更好的管理配置文件的方法
  cfp = config.modules.proxy;
  cfg = cfp.sing-box;
  cfgbin = "${cfg.package}/bin/${cfg.package.pname}";
  workdir = "${config.home.cacheDir}/sing-box";
in {
  options.modules.proxy.sing-box = {
    enable = mkBoolOpt false;
    configFile = mkOpt' types.str (
      if cfp.default == "sing-box"
      then cfp.configFile
      else "${config.home.configDir}/sing-box/config.json"
    ) ''sing-box 配置文件保存位置'';
    package = mkPkgOpt pkgs.sing-box "sing-box service";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [cfg.package];
    }
    (mkIf (cfp.default == "sing-box") {
      modules.proxy.service.cmd = mkDefault ''sudo ${cfgbin} run -c "${cfg.configFile}" -D "${workdir}"'';
    })
  ]);
}
