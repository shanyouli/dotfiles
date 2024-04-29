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
  cfg = cfm.shell.elvish;
in {
  options.modules.shell.elvish = {
    enable = mkEnableOption "Whether to elvish";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.unstable.elvish];
  };
}
