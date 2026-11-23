{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.editor;
  cfg = config.modules.macos.editor;
in
{
  options.modules.macos.editor = {
    enable = mkEnableOption "是否使用 macos 编辑工具";
    logseq.enable = mkBoolOpt false; # 安装 logseq note 工具
  };
  config = {
    homebrew.casks = [
      # logseq 开始使用数据库管理文件，并且对 org 的支持仅支持预览
      (mkIf cfg.logseq.enable "logseq")

      (mkIf ((cfp.zed.package == null) && cfp.zed.enable) "zed")
      (mkIf (
        config.modules.editor.nvim.enGui && config.modules.editor.nvim.enable
      ) "shanyouli/tap/neovide-pure")
    ]
    ++ optionals cfg.enable [
      "shanyouli/tap/winc" # 或者 "lite-edit" "coteditor"
      "shanyouli/tap/nomo" # markdown 编写工具，可以媲美 typora
    ];
  };
}
