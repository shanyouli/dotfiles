{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.rsync;
in {
  options.modules.rsync = {
    enable = mkEnableOption "Whether to use rsync";
    package = mkOpt' types.package pkgs.rsync "";
  };
  config = mkIf cfg.enable {
    user.packages = [cfg.package];
    modules.shell.pluginFiles = ["rsync"];
  };
}
