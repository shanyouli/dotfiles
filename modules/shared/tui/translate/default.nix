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
  cfp = config.modules;
  cfg = cfp.translate;
in {
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
    (mkIf cfg.sdcv.enable {
      # 使用 sdcv 本地翻译工具
      home.packages = with pkgs; [sdcv] ++ optionals stdenvNoCC.isx86_64 [libretranslate];
      modules.shell.env = {
        STARDICT_DATA_DIR = "${config.home.dataDir}/stardict";
        SDCV_HISTSIZE = "100000";
        SDCV_HISTFILE = "${config.home.cacheDir}/sdcv_history";
      };
    })
    (mkIf cfg.remote.enable {
      # awk 编写的 google 翻译工具
      home.packages = [pkgs.translate-shell];
    })
    (mkIf cfg.deeplx.enable {
      home.packages = [pkgs.unstable.deeplx];
    })
  ]);
}
