# NOTE: 如果你使用 ice，请在设置不显示 menubar 时，修改系统设置是否隐藏 menubar 为 never
# 在修改完后，在修改到你喜欢的 menubar 显示模式。具体原因见: @https://github.com/jordanbaird/Ice/issues/201
# ice 工具暂不支持在总是隐藏 menubar 的状态下工作。
{
  lib,
  config,
  options,
  my,
  pkgs,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos;
  cfg = cfp.ui;
  cfgPkg = if cfg.ice.enable then "jordanbaird-ice" else "hiddenbar"; # or "dozer";
in
{
  options.modules.macos.ui = {
    ice.enable = mkBoolOpt false;
  };
  config = {
    homebrew.casks = [
      # "onyx" # 系统配置修改 GUI 工具
      cfgPkg
      "launchpadder" # 排序 launchpad
    ];
    user.packages = [
      pkgs.unstable.darwinapps.lporg # 自定义 launchpad 布局
      pkgs.unstable.openlist
    ];
  };
}
