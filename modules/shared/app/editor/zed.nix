# 具体配置参考
# @see: https://zed.dev/docs/getting-started
#       https://www.kevnu.com/zh/posts/zed-editor-configuration-guide-autosave-prettier-terminal-font-and-formatting-made-easy#%E5%AE%8C%E6%95%B4%E9%85%8D%E7%BD%AE
#       https://northes.io/posts/editor/zed/
#       https://linux.do/t/topic/185158
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
  cfp = config.modules.app.editor;
  cfg = cfp.zed;
  rsyncbin =
    if config.modules.rsync.enable then getExe config.modules.rsync.package else getExe pkgs.rsync;
in
{
  options.modules.app.editor.zed = {
    enable = mkEnableOption "Whether to use zed editor";
    package = mkPackageOption pkgs "zed-editor" { };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    my.user.init.SyncZed = ''
      ${rsyncbin} -avz --chmod=D2755,F744 ${my.dotfiles.config}/zed/ "${config.home.configDir}/zed/"
    '';
  };
}
