{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.shell.atuin;
in {
  options.modules.shell.atuin = {
    enable = mkEnableOption "Using the database to manage shell history";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.stable.atuin];
  };
}
