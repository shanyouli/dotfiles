# 安装 adb 工具， rom 解包工具， scrcpy 交互工具
{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfg = config.modules.adb;
  package = mkHomePkg pkgs.android-tools config.home.fakeDir;
in {
  options.modules.adb = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = [package pkgs.payload-dumper-go pkgs.scrcpy];
    modules.shell.env.ANDROID_USER_HOME = "${config.home.fakeDir}/.android";
  };
}
