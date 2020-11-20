{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.shell.sdcv;
in {
  options.modules.shell.sdcv = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = [ pkgs.sdcv ];
    env.STARDICT_DATA_DIR = "$XDG_DATA_HOME/sdcv";
    env.SDCV_HISTSIZE = "10000";
    env.SDCV_HISTFILE = "$HOME/projects/org/dict.org";

    # modules.shell.zsh.aliases =
  };
}
