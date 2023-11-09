{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.my.modules.direnv;
in {
  options.my.modules.direnv = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.user.packages = [ pkgs.direnv ];
    my.modules.zsh.rcInit = ''_cache direnv hook zsh'';
    my.hm.configFile."direnv"= {
      source = "${configDir}/direnv";
      recursive = true;
    };
  };
}
