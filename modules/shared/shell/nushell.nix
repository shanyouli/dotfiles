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
  cfg = cfm.shell.nushell;
in {
  options.modules.shell.nushell = {
    enable = mkEnableOption "A more modern shell";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.unstable.nushell];
  };
}
