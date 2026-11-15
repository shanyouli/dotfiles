{
  lib,
  config,
  pkgs,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.shell.terminal;
  terminals = [
    "kitty"
    "wezterm"
    "alacritty"
    "ghostty"
  ];
in
{
  options.modules.shell.terminal = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = str: if builtins.elem str terminals then str else "";
      description = "Default terminal simulators";
    };
    font = {
      size = mkNumOpt 10;
      family = mkStrOpt "Cascadia Code";
      package = mkPackageOption pkgs "cascadia-code" { };
    };
  };
  config = mkIf ((cfg.default != "") && config.modules.fonts.enable) (mkMerge [
    { modules.fonts.packages = with pkgs; [ cfg.font.package ]; }
    (mkIf (cfg.default == "kitty") { modules.shell.terminal.kitty.enable = true; })
    (mkIf (cfg.default == "wezterm") { modules.shell.terminal.wezterm.enable = true; })
    (mkIf (cfg.default == "alacritty") { modules.shell.terminal.alacritty.enable = true; })
    (mkIf (cfg.default == "ghostty") { modules.shell.terminal.ghostty.enable = true; })
  ]);
}
