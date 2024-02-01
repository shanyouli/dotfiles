{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.browser.chrome;
  cfgPkg =
    if pkgs.stdenvNoCC.isLinux
    then pkgs.google-chrome
    else pkgs.chrome-app;
in {
  options.modules.browser.chrome = {
    enable = mkEnableOption "Whether to google-chrome";
    dev.enable = mkBoolOpt true;
    useBrew = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    user.packages = [
      (mkIf (! cfg.useBrew) cfgPkg)
      (mkIf cfg.dev.enable pkgs.chromedriver)
    ];
  };
}
