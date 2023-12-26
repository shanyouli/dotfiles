{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.wezterm;
in {
  options.modules.wezterm = with types; {
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
