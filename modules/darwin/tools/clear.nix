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
  cfg = cfp.tools.clear;
in
{
  options.modules.macos.tools.clear = {
    enable = mkEnableOption "Whether to install clear tools.";

  };
  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "tencent-lemon" # 文件清理 or ""clean-me""
        "pearcleaner" # app 卸载工具 or "appcleaner"
      ];
      brews = [ "mole" ];
    };
  };
}
