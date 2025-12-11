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
in
{
  options.modules.app.editor.zed = {
    enable = mkEnableOption "Whether to use zed editor";
    package = mkPackageOption pkgs "zed-editor" { };
  };
  config = mkIf cfg.enable { home.packages = [ cfg.package ]; };
}
