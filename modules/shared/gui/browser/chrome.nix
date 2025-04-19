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
  cfm = config.modules.gui;
  cfg = cfm.browser.chrome;
in
{
  options.modules.gui.browser.chrome = {
    enable = mkEnableOption "Whether to google-chrome";
    dev.enable = mkBoolOpt true;
    useBrew = mkBoolOpt pkgs.stdenvNoCC.isDarwin;
    package = mkOption {
      type = types.package;
      default = if pkgs.stdenvNoCC.isLinux then pkgs.google-chrome else pkgs.unstable.darwinapps.chrome;
      defaultText = literalExample "pkgs.google-chrome";
      example = literalExample "pkgs.google-chrome";
      description = "The Chrome module to use.";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.dev.enable {
      home.packages = [ pkgs.chromedriver ];
      modules.gopass.browsers = [
        "chrome"
        "chromium"
      ];
    })
    (mkIf (!cfg.useBrew) { home.packages = [ cfg.package ]; })
  ]);
}
