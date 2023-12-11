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
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.user.packages = [pkgs.rsync];
    modules.zsh.rcFiles = ["${configDir}/rsync/rsync.zsh"];
  };
}
