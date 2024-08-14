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
  cfg = cfm.fonts;
in {
  options.modules.fonts = {
    enable = mkBoolOpt config.modules.gui.enable;
    term = {
      family = mkStrOpt "Cascadia Code";
      size = mkNumOpt 10;
      package = mkPkgOpt pkgs.cascadia-code "Cascadia Code font";
    };
  };
  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [cfg.term.package];
    };
  };
}
