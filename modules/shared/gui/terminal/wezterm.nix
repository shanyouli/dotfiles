{
  config,
  options,
  pkgs,
  lib,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.gui.terminal.wezterm;
in
{
  options.modules.gui.terminal.wezterm = with types; {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.wezterm ];
    home.configFile."wezterm" = {
      source = "${my.dotfiles.config}/wezterm";
      recursive = true;
    };
  };
}
