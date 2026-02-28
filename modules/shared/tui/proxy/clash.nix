{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  # TODO: 设置更好的管理配置文件的方法
  cfp = config.modules.proxy;
  cfg = cfp.clash;
  workdir = "${config.home.cacheDir}/clash";
  cfgbin = "${cfg.package}/bin/${cfg.package.pname}";
in
{
  options.modules.proxy.clash = {
    enable = mkBoolOpt false;
    configFile = mkOpt' types.str (
      if (cfp.default == "clash") then
        cfp.configFile
      else
        "${config.home.configDir}/clash-meta/clash.yaml"
    ) "clash 配置文件保存位置";
    package = mkPackageOption pkgs "mihomo" { };
  };
  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ cfg.package ]; }
    (mkIf (cfp.default == "clash") {
      modules.proxy.service.cmd = mkDefault ''sudo ${cfgbin} -f "${cfg.configFile}" -d "${workdir}"'';
    })
  ]);
}
