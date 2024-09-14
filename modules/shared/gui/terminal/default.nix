{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.gui.terminal;
  terminals = ["kitty" "wezterm" "alacritty"];
in {
  options.modules.gui.terminal = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = str:
        if builtins.elem str terminals
        then str
        else "";
      description = "Default terminal simulators";
    };
    font = {
      size = mkNumOpt 10;
      family = mkStrOpt "Cascadia Code";
      package = mkPkgOpt pkgs.cascadia-code "Cascadia Code font";
    };
  };
  config = mkIf ((cfg.default != "") && config.modules.gui.enable) (
    mkMerge [
      {
        modules.gui.fonts = with pkgs; [cfg.font.package];
      }
      (mkIf (cfg.default == "kitty") {
        modules.gui.terminal.kitty.enable = true;
      })
      (mkIf (cfg.default == "wezterm") {
        modules.gui.terminal.wezterm.enable = true;
      })
      (mkIf (cfg.default == "alacritty") {
        modules.gui.terminal.alacritty.enable = true;
      })
    ]
  );
}
