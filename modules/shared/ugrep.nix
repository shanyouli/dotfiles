{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.ugrep;
in {
  options.my.modules.ugrep = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.user.packages = [pkgs.ugrep];
    my.modules.zsh.rcFiles = ["${configDir}/ugrep/ugrep.zsh"];
  };
}
