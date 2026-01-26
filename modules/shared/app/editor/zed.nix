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
    if config.modules.tui.rsync.enable then
      getExe config.modules.tui.rsync.package
    else
      getExe pkgs.rsync;
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
