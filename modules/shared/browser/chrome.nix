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
in {
  options.modules.browser.chrome = {
    enable = mkEnableOption "Whether to google-chrome";
    dev.enable = mkBoolOpt true;
    useBrew = mkBoolOpt false;
    package = mkOption {
      type = types.package;
      default =
        if pkgs.stdenvNoCC.isLinux
        then pkgs.google-chrome
        else pkgs.stable.chrome-app;
      defaultText = literalExample "pkgs.google-chrome";
      example = literalExample "pkgs.google-chrome";
      description = "The Chrome module to use.";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.dev.enable {
      user.packages = [pkgs.chromedriver];
      modules.shell.gopass.browsers = ["chrome" "chromium"];
    })
    (mkIf (! cfg.useBrew) {
      user.packages = [cfg.package];
    })
  ]);
}
