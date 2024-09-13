{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.theme;
in {
  options.modules.theme = {
    default = mkStrOpt "catppuccin";
    script = mkStrOpt "";
  };
  config = {
    modules.theme.catppuccin.enable = cfg.default == "catppuccin";
  };
}
