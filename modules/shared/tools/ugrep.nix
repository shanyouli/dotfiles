{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.tools.ugrep;
in
{
  options.modules.tools.ugrep = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ugrep ];
    modules.shell.zsh.pluginFiles = [ "ugrep" ];
  };
}
