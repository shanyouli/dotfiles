{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.ugrep;
in {
  options.modules.ugrep = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.user.packages = [pkgs.ugrep];
    modules.zsh.rcFiles = ["${configDir}/ugrep/ugrep.zsh"];
  };
}
