{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.sdcv;
in {
  options.modules.sdcv = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    # 主要使用了 sdcv 本地翻译工具
    # deeplx 一个deepl非官方api调用服务工具服
    # google-translate python 编写的google翻译工具
    # crow-translate 一个多后端的翻译工具可惜不支持mac
    user.packages = with pkgs;
      [sdcv translate-shell]
      ++ optionals stdenvNoCC.isLinux [crow-translate];
    modules.shell.env.STARDICT_DATA_DIR = "${config.my.hm.dataHome}/stardict";
    modules.shell.env.SDCV_HISTSIZE = "100000";
    modules.shell.env.SDCV_HISTFILE = "${config.my.hm.cacheHome}/sdcv_history";
  };
}
