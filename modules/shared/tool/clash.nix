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
  cfg = config.modules.tool.clash;
  cm = config.modules;
  proxy = "http://127.0.0.1:10801";
in {
  options.modules.tool.clash = {
    enable = mkBoolOpt false;
    enSingbox = mkBoolOpt false;
    configFile = mkOpt' types.path "${config.home.configDir}/clash-meta/clash.yaml" ''
      clash 配置文件保存位置
    '';
    package = mkPkgOpt pkgs.clash-meta "clash service";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.etc."sudoers.d/clash".text =
        sudoNotPass config.user.name "${cfg.package}/bin/${cfg.package.pname}";
    }
    (mkIf cm.tool.aria2.enable {
      modules.shell.aliases.paria2 = "aria2c --all-proxy=${proxy}";
    })
    (mkIf cfg.enSingbox {
      user.packages = [pkgs.clash2singbox];
    })
  ]);
}
