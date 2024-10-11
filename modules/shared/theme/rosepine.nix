{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.theme;
  cfg = cfp.rosepine;
  dark_themes = ["main" "moon"];
in {
  options.modules.theme.rosepine = {
    enable = mkEnableOption "Whether to use rose-pine themes.";
    light = mkStrOpt "dawn";
    dark = mkOption {
      type = types.str;
      default = "main";
      apply = str:
        if builtins.elem str dark_themes
        then str
        else "main";
    };
  };
  config =
    mkIf cfg.enable {
    };
}
