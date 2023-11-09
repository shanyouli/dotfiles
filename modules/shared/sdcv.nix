{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.sdcv;
in {
  options.my.modules.sdcv = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    # 主要使用了 sdcv 本地翻译工具
    # deeplx 一个deepl非官方api调用服务工具服
    # google-translate python 编写的google翻译工具
    # crow-translate 一个多后端的翻译工具可惜不支持mac
    my.user.packages = with pkgs;
      [sdcv deeplx translate-shell]
      ++ optionals stdenvNoCC.isLinux [crow-translate];
    my.modules.zsh.env.STARDICT_DATA_DIR = "${config.my.hm.dataHome}/stardict";
    my.modules.zsh.env.SDCV_HISTSIZE = "100000";
    my.modules.zsh.env.SDCV_HISTFILE = "${config.my.hm.cacheHome}/sdcv_history";
  };
}
