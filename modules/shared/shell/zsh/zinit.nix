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
  cfm = config.modules;
  cfg = cfm.shell.zsh.zinit;
  cpkgs = pkgs.zinit;
in
{
  options.modules.shell.zsh.zinit = {
    enable = mkEnableOption "WHether to use zsh plugin manager (zinit)";
  };
  config = mkIf cfg.enable {
    modules.shell.env.ZINIT_HOME = "${cpkgs}/share/zinit";
    home.packages = [ cpkgs ];
  };
}
