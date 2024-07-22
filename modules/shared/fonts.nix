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
    enable = mkBoolOpt config.modules.opt.enGui;
    term = {
      family = mkStrOpt "Cascadia Code";
      size = mkNumOpt 10;
      package = mkPkgOpt pkgs.cascadia-code "Cascadia Code font";
    };
  };
  config = mkIf cfg.enable {
    fonts = {
      # fontDir.enable = true;
      packages = with pkgs; [
        fantasque-sans-mono
        cfg.term.package
        lxgw-wenkai
        unifont
        (nerdfonts.override {fonts = ["FantasqueSansMono" "NerdFontsSymbolsOnly"];})
      ];
    };
  };
}
