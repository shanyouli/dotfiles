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
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.dev.enable {
      user.packages = [pkgs.chromedriver];
    })
    (mkIf (! cfg.useBrew) {
      user.packages = [cfgPkg];
      modules.shell.gopass.browsers = ["chrome"];
    })
  ]);
}
