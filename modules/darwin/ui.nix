# NOTE: 如果你使用 ice，请在设置不显示 menubar 时，修改系统设置是否隐藏 menubar 为 never
# 在修改完后，在修改到你喜欢的 menubar 显示模式。具体原因见: @https://github.com/jordanbaird/Ice/issues/201
# ice 工具暂不支持在总是隐藏 menubar 的状态下工作。
{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.macos;
  cfg = cfp.ui;
in {
  options.modules.macos.ui = {
    ice.enable = mkBoolOpt true;
  };
  config = {
    homebrew.casks =
      optionals cfg.ice.enable [
        "jordanbaird-ice" # tab 自动隐藏, 其他 "dozer" # 菜单栏管理,
        # "hiddenbar"
      ]
      ++ ["onyx"]; # onyx 配置修改工具
    home.initExtra = optionalString (! cfg.ice.enable) (mkOrder 10000 ''
      print $"Please use (ansi green_bold)Apple Store(ansi reset) install (ansi u)Ibar(ansi reset)."
    '');
  };
}
