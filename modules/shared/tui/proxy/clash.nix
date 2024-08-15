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
  cfg = config.modules.proxy.clash;
  workdir = "${config.home.cacheDir}/clash";
  cmdName =
    if cfg.package.pname == "clash-meta"
    then "clash-meta"
    else "mihomo";
in {
  options.modules.proxy.clash = {
    enable = mkBoolOpt false;
    configFile = mkOpt' types.path "${config.home.configDir}/clash-meta/clash.yaml" ''
      clash 配置文件保存位置
    '';
    package = mkPkgOpt pkgs.mihomo "clash service";
    serviceCmd = mkStrOpt "";
  };
  config = mkIf cfg.enable {
    user.packages = [cfg.package];
    environment.etc."sudoers.d/clash".text =
      sudoNotPass config.user.name "${cfg.package}/bin/${cfg.package.pname}";
    modules.proxy.clash.serviceCmd = ''sudo ${cfg.package}/bin/${cmdName} -f "${cfg.configFile}" -d "${workdir}"'';
  };
}
