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
  cfg = cfp.fonts;
in
{
  options.modules.fonts = {
    enable = mkEnableOption "whether to use gui apps";
    packages = mkOpt' (types.listOf types.package) [ ] "font install";
  };
  config = mkIf cfg.enable {
    modules.fonts.packages = with pkgs; [
      lxgw-wenkai
      unifont
      # sarasa-term
      nerd-fonts.fantasque-sans-mono # fantasque-sans-mono
      nerd-fonts.symbols-only
      maple-mono-nf-vf # maple-mono-vf
      maple-mono-nf-cn-vf # maple-mono-cn-vf
      pragmasevka-nerd # pragmasevka
      pragmasevka-sans
      pragmasevka-serif
      pragmasevka-sc-nf # pragmasevka-sc
    ];
  };
}
