{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfm = config.modules;
  cfg = cfm.theme;
  get_palette = theme: type:
    builtins.fromJSON (builtins.readFile "${dotfiles.config}/themes/${theme}/palette/${type}.json");
in {
  options.modules.theme = {
    default = mkStrOpt "catppuccin";
    mode = mkStrOpt "dark";
    script = mkStrOpt "";
    palettes = {
      dark = mkOpt' types.attrs {} "dark palettes";
      light = mkOpt' types.attrs {} "light palettes";
    };
  };
  config = mkMerge [
    (mkIf (cfg.default == "catppuccin") {
      modules.theme = {
        catppuccin.enable = mkForce true;
        palettes = {
          dark = get_palette "catppuccin" cfg.catppuccin.dark;
          light = get_palette "catpuccin" cfg.catppuccin.light;
        };
      };
    })
  ];
}
