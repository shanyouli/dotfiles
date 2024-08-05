{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.shell;
  cfg = cfp.fastfetch;
in {
  options.modules.shell.fastfetch = {
    enable = mkEnableOption "Whether to use fastfetch";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.fastfetch];
  };
}
