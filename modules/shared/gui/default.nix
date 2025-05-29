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
    modules.gui.fonts = [
      pkgs.fantasque-sans-mono
      pkgs.lxgw-wenkai
      pkgs.unifont
      # pkgs.unstable.sarasa-term
      pkgs.unstable.maple-mono.NF
      pkgs.unstable.maple-mono.NF-CN
      pkgs.nerd-fonts.fantasque-sans-mono
      pkgs.nerd-fonts.symbols-only
      pkgs.unstable.pragmasevka
      pkgs.unstable.pragmasevka-nerd
      pkgs.unstable.pragmasevka-sans
      pkgs.unstable.pragmasevka-sc-nf
      pkgs.unstable.pragmasevka-serif
    ];
    # fonts = {
    #   # fontDir.enable = true;
    #   packages = with pkgs; [
    #   ];
    # };
  };
}
