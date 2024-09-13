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
    home.packages = [pkgs.ugrep];
    modules.shell.zsh.pluginFiles = ["ugrep"];
  };
}
