{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.terminal;
  terminals = ["kitty" "wezterm" "alacritty"];
in {
  options.modules.terminal = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = str:
        if builtins.elem str terminals
        then str
        else "";
      description = "Default terminal simulators";
    };
  };
  config = mkIf (cfg.default != "") (
    mkMerge [
      (mkIf (cfg.default == "kitty") {
        modules.terminal.kitty.enable = true;
      })
      (mkIf (cfg.default == "wezterm") {
        modules.terminal.wezterm.enable = true;
      })
    ]
  );
}
