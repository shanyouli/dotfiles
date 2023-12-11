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
    enable = mkBoolOpt config.my.enGui;
  };
  config = mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;
      fonts = with pkgs; [
        fantasque-sans-mono
        cascadia-code
        lxgw-wenkai
        unifont
        (nerdfonts.override {fonts = ["FantasqueSansMono" "NerdFontsSymbolsOnly"];})
        # maple-mono
        # maple-sc
        # codicons # vscode icons 字体
        julia-mono
        monaspace
      ];
    };
  };
}
