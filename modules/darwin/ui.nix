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
        # "jordanbaird-ice" # tab 自动隐藏, 其他 "dozer" # 菜单栏管理,
        "hiddenbar"
      ]
      ++ ["onyx"]; # onyx 配置修改工具
    home.initExtra = optionalString (! cfg.ice.enable) (mkOrder 10000 ''
      print $"Please use (ansi green_bold)Apple Store(ansi reset) install (ansi u)Ibar(ansi reset)."
    '');
  };
}
