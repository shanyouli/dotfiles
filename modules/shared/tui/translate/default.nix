{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.tui;
  cfg = cfp.translate;
in {
  options.modules.tui.translate = {
    enable = mkEnableOption "whether to use translate tools";
    sdcv.enable = mkBoolOpt true;
    remote.enable = mkBoolOpt true;
    deeplx.enable = mkBoolOpt true;
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.sdcv.enable {
      # 使用 sdcv 本地翻译工具
      user.packages = with pkgs; [sdcv] ++ optionals stdenvNoCC.isx86_64 [libretranslate];
      modules.shell.env.STARDICT_DATA_DIR = "${config.home.dataDir}/stardict";
      modules.shell.env.SDCV_HISTSIZE = "100000";
      modules.shell.env.SDCV_HISTFILE = "${config.home.cacheDir}/sdcv_history";
    })
    (mkIf cfg.remote.enable {
      # awk 编写的 google 翻译工具
      user.packages = [pkgs.translate-shell];
    })
    (mkIf cfg.deeplx.enable {
      user.packages = [pkgs.unstable.deeplx];
    })
  ]);
}
