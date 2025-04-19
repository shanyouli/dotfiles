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
  cfp = config.modules;
  cfg = cfp.gui;
in
{
  options.modules.gui = {
    enable = mkEnableOption "whether to use gui apps";
    fonts = mkOpt' (types.listOf types.package) [ ] "font install";
  };
  config = mkIf cfg.enable {
    modules.gui.fonts = with pkgs; [
      fantasque-sans-mono
      lxgw-wenkai
      unifont
      pkgs.unstable.sarasa-term
      (nerdfonts.override {
        fonts = [
          "FantasqueSansMono"
          "NerdFontsSymbolsOnly"
          # "CascadiaCode" # cascadiaCode 自带
        ];
      })
      pkgs.unstable.pragmasevka
      pkgs.unstable.pragmasevka-nerd
      pkgs.unstable.pragmasevka-serif
      pkgs.unstable.pragmasevka-sans
    ];
    # fonts = {
    #   # fontDir.enable = true;
    #   packages = with pkgs; [
    #   ];
    # };
  };
}
