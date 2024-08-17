{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules.gui;
  cfg = cfm.browser.chrome;
in {
  options.modules.gui.browser.chrome = {
    enable = mkEnableOption "Whether to google-chrome";
    dev.enable = mkBoolOpt true;
    useBrew = mkBoolOpt pkgs.stdenvNoCC.isDarwin;
    package = mkOption {
      type = types.package;
      default =
        if pkgs.stdenvNoCC.isLinux
        then pkgs.google-chrome
        else pkgs.unstable.darwinapps.chrome;
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
