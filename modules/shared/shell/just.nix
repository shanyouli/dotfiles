# see @https://github.com/casey/just/blob/master/README.%E4%B8%AD%E6%96%87.md
# 本地快捷方法
{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.shell.just;
in {
  options.modules.shell.just = {
    enable = mkEnableOption "Whether to use just";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.just];
  };
}
