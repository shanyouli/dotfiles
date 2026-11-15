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
  cfp = config.modules.network;
  cfg = cfp.tg;
in
{
  options.modules.network.tg = {
    enable = mkEnableOption "Whether to use tg";
    package = mkPackageOption pkgs "telegram-desktop" {
      nullable = true;
      extraDescription = "If this value is null, homebrew will be used for management.";
    };
  };
  config = mkIf (cfg.enable && (cfg.package != null)) { home.packages = [ cfg.package ]; };
}
