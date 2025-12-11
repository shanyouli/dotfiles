{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.themes;
in
{
  options.modules.themes = {
    default = mkOption {
      type = types.str;
      default = "";
      apply =
        s:
        if
          builtins.elem s [
            "wal"
            "base16"
          ]
        then
          s
        else
          "";
    };
    use = mkOption {
      type = types.str;
      default = "dark";
      apply =
        s:
        if
          builtins.elem s [
            "auto"
            "dark"
            "light"
          ]
        then
          s
        else
          "dark";
    };
  };
  config = {
    modules.themes.wal.enable = mkForce (cfg.default == "wal");
  };
}
