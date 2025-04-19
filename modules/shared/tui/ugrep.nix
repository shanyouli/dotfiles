{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.ugrep;
in
{
  options.modules.ugrep = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ugrep ];
    modules.shell.zsh.pluginFiles = [ "ugrep" ];
  };
}
