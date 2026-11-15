{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.network.safari;
in
{
  options.modules.macos.network.safari = {
    enable = mkEnableOption "Use some extensions on safari";
  };
  config = mkIf cfg.enable {
    homebrew.masApps = {
      "Userscript" = 1463298887; # tampermonkey
      "vimari" = 1480933944; # vim 控制safari
      # "immersive-translate" = 6447957425; # 双语翻译
      # "adblock" = 1018301773;
    };
  };
}
