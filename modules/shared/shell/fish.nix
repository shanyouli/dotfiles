{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.shell;
  cfg = cfp.fish;
in {
  options.modules.shell.fish = {
    enable = mkEnableOption "Whether to use fish";
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.fish];
  };
}
