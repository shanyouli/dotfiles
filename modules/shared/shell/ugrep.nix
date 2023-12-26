{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.ugrep;
in {
  options.modules.shell.ugrep = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = [pkgs.ugrep];
    modules.shell.rcFiles = ["${config.dotfiles.configDir}/ugrep/ugrep.zsh"];
  };
}
