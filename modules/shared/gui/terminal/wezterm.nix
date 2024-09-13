{
  config,
  options,
  pkgs,
  lib,
  myvars,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.gui.terminal.wezterm;
in {
  options.modules.gui.terminal.wezterm = with types; {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.wezterm];
    home.configFile."wezterm" = {
      source = "${myvars.dotfiles.config}/wezterm";
      recursive = true;
    };
  };
}
