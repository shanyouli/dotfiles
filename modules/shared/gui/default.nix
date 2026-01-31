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
    modules.gui.fonts = [
      pkgs.fantasque-sans-mono
      pkgs.lxgw-wenkai
      pkgs.unifont
      # pkgs.sarasa-term
      pkgs.maple-mono.NF
      pkgs.maple-mono.NF-CN
      pkgs.nerd-fonts.fantasque-sans-mono
      pkgs.nerd-fonts.symbols-only
      pkgs.pragmasevka
      pkgs.pragmasevka-nerd
      pkgs.pragmasevka-sans
      pkgs.pragmasevka-sc-nf
      pkgs.pragmasevka-sc
      pkgs.pragmasevka-serif
    ];
    # fonts = {
    #   # fontDir.enable = true;
    #   packages = with pkgs; [
    #   ];
    # };
  };
}
