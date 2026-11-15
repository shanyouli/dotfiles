{
  config,
  pkgs,
  lib,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.shell.terminal.wezterm;
in
{
  options.modules.shell.terminal.wezterm = with types; {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.wezterm ];
    home.configFile."wezterm" = {
      source = "${my.paths.dotfiles.config}/wezterm";
      recursive = true;
    };
  };
}
