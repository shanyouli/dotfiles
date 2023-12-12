{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.rsync;
in {
  options.modules.shell.rsync = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.user.packages = [pkgs.rsync];
    modules.shell.rcFiles = ["${configDir}/rsync/rsync.zsh"];
  };
}
