# see @https://github.com/casey/just/blob/master/README.%E4%B8%AD%E6%96%87.md
# 本地快捷方法
{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.just;
in
{
  options.modules.just = {
    enable = mkEnableOption "Whether to use just";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.just ]; };
}
