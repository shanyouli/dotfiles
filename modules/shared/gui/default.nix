{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules;
  cfg = cfp.gui;
in {
  options.modules.gui = {
    enable = mkEnableOption "whether to use gui apps";
  };
  config = mkIf cfg.enable {
    fonts = {
      # fontDir.enable = true;
      packages = with pkgs; [
        fantasque-sans-mono
        lxgw-wenkai
        unifont
        (nerdfonts.override {fonts = ["FantasqueSansMono" "NerdFontsSymbolsOnly" "CascadiaCode"];})
      ];
    };
  };
}
