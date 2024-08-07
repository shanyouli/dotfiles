{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.terminal.wezterm;
in {
  options.modules.terminal.wezterm = with types; {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.wezterm];
    home.configFile."wezterm" = {
      source = "${config.dotfiles.configDir}/wezterm";
      recursive = true;
    };
  };
}
