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
  cfg = config.modules.clash;
  cm = config.modules;
  proxy = "http://127.0.0.1:10801";
in {
  options.modules.clash = {
    enable = mkBoolOpt false;
    configFile = mkOpt' types.path "${config.my.hm.configHome}/clash-meta/clash.yaml" ''
      clash 配置文件保存位置
    '';
    package = mkPkgOpt pkgs.clash-meta "clash service";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # my.user.packages = [pkgs.clash-meta];
      environment.etc."sudoers.d/clash".text =
        sudoNotPass config.my.username "${cfg.package}/bin/${cfg.package.pname}";
    }
    (mkIf cm.aria2.enable {
      modules.shell.aliases.paria2 = "aria2c --all-proxy=${proxy}";
    })
  ]);
}
