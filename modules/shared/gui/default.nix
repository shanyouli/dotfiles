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
      fantasque-sans-mono
      lxgw-wenkai
      unifont
      sarasa-term
      # unable.maple-mono.NF
      # unable.maple-mono.NF-CN
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.symbols-only
      pragmasevka
      pragmasevka-nerd
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
