{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.direnv;
in {
  options.modules.shell.direnv = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.user.packages = [pkgs.direnv];
    modules.shell.rcInit = ''_cache direnv hook zsh'';
    my.hm.configFile."direnv" = {
      source = "${configDir}/direnv";
      recursive = true;
    };
  };
}
