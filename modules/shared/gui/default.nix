{
  pkgs,
  lib,
  config,
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
      lxgw-wenkai
      unifont
      # sarasa-term
      nerd-fonts.fantasque-sans-mono # fantasque-sans-mono
      nerd-fonts.symbols-only
      maple-mono-vf
      maple-mono-nf-vf
      maple-mono-cn-vf
      maple-mono-nf-cn-vf
      pragmasevka-nerd # pragmasevka
      pragmasevka-sans
      pragmasevka-sc-nf
      pragmasevka-sc
      pragmasevka-serif
    ];
    # fonts = {
    #   # fontDir.enable = true;
    #   packages = with pkgs; [
    #   ];
    # };
  };
}
