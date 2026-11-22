{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.macos.tools;
  cfg = cfp.finder;
in
{
  options.modules.macos.tools.finder = {
    enable = mkEnableOption "Whether to finder 扩展";
    space.enable = mkBoolOpt true; # 增强 space 空格预览
    terminal.enable = mkBoolOpt false; # 在 finder 中对应目录打开指定终端
  };
  config = mkIf cfg.enable {
    homebrew.casks = [
      (mkIf cfg.terminal.enable "findergo")
      (mkIf cfg.space.enable "shanyouli/tap/spacepreview")
      # 其它的 预览工具
      "syntax-highlight"
      "qlmarkdown" # markdown
      "macpacker" # zip 文件预览
    ];

  };
}
