{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules;
  cfg = cfp.translate;
in
{
  options.modules.translate = {
    enable = mkEnableOption "whether to use translate tools";
    sdcv.enable = mkBoolOpt true;
    remote.enable = mkBoolOpt true;
    deeplx = {
      enable = mkBoolOpt cfg.enable;
      service = {
        enable = mkBoolOpt cfg.deeplx.enable;
        startup = mkBoolOpt true;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        mtranserver
        # libretranslate 也许 mtranserver 更好
        # (mkIf stdenvNoCC.isx86_64 libretranslate)
        (mkIf cfg.deeplx.enable pkgs)
        # awk 编写的 google 翻译工具
        (mkIf cfg.remote.enable translate-shell)
        (mkIf cfg.sdcv.enable sdcv)
      ];

    }
    (mkIf cfg.sdcv.enable {
      # 使用 sdcv 本地翻译工具
      modules.shell.env = {
        STARDICT_DATA_DIR = "$XDG_DATA_HOME/stardict";
        SDCV_HISTSIZE = "100000";
        SDCV_HISTFILE = "$XDG_CACHE_HOM/sdcv_history";
      };
    })
  ]);
}
