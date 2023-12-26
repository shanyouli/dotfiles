{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.terminal;
in {
  options.modules.terminal = {
    default = mkStrOpt "kitty";
  };
  config = mkMerge [
    (mkIf (cfg.default == "kitty") {
      modules.kitty.enable = true;
    })
    (mkIf (cfg.default == "wezterm") {
      modules.wezterm.enable = true;
    })
  ];
}
