{pkgs, lib, config, options, ...}:
with lib;
with lib.my;
let cfg = config.my.modules.rsync;
in {
  options.my.modules.rsync = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.user.packages = [ pkgs.rsync ];
    my.modules.zsh.rcFiles = [ "${configDir}/rsync/rsync.zsh" ];
  };
}
