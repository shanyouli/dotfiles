{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.app;
  cfg = cfp.tg;
in
{
  options.modules.app.tg = {
    enable = mkEnableOption "Whether to use tg";
    package = mkPackageOption pkgs "telegram-desktop" { };
  };
  config = mkIf cfg.enable { home.packages = [ cfg.package ]; };
}
