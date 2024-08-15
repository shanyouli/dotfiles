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
  cfg = config.modules.proxy.sing-box;
  workdir = "${config.home.cacheDir}/sing-box";
in {
  options.modules.proxy.sing-box = {
    enable = mkBoolOpt false;
    configFile = mkOpt' types.path "${config.home.configDir}/sing-box/config.json" ''
      sing-box 配置文件保存位置
    '';
    package = mkPkgOpt pkgs.sing-box "sing-box service";
    serviceCmd = mkStrOpt "";
  };
  config = mkIf cfg.enable {
    user.packages = [cfg.package];
    environment.etc."sudoers.d/singbox".text =
      sudoNotPass config.user.name "${cfg.package}/bin/${cfg.package.pname}";
    modules.proxy.sing-box.serviceCmd = ''sudo ${cfg.package}/bin/sing-box run -c "${cfg.configFile}" -D "${workdir}"'';
  };
}
