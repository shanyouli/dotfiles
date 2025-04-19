{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos;
  cfg = cfp.read;
in
{
  options.modules.macos.read = {
    enable = mkEnableOption "Whether to use read tools.";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [
      "skim" # PDF
      "calibre" # "koodo-reader", 书籍管理和阅读
      # "shanyouli/tap/alexandria" # 阅读工具
      "shanyouli/tap/readest"
    ];
  };
}
