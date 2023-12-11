{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; {
  options.modules.terminal = {
    default = mkStrOpt config.my.terminal;
  };
  config = mkMerge [
    (mkIf (config.my.terminal == "kitty") {
      modules.kitty.enable = true;
    })
    (mkIf (config.my.terminal == "wezterm") {
      modules.wezterm.enable = true;
    })
  ];
}
