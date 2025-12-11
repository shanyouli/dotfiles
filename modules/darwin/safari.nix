{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos;
  cfg = cfp.safari;
in
{
  options.modules.macos.safari = {
    enable = mkEnableOption "Use some extensions on safari";
  };
  config = mkIf cfg.enable {
    homebrew.masApps = {
      "Userscript" = 1463298887; # tampermonkey
      "vimari" = 1480933944; # vim 控制safari
      "immersive-translate" = 6447957425; # 双语翻译
      # "adblock" = 1018301773;
    };
  };
}
