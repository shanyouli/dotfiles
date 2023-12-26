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
    user.packages = [pkgs.rsync];
    modules.shell.rcFiles = ["${config.dotfiles.configDir}/rsync/rsync.zsh"];
  };
}
