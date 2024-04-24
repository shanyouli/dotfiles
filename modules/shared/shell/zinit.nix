{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.shell.zinit;
  cpkgs = pkgs.zinit;
in {
  options.modules.shell.zinit = {
    enable = mkEnableOption "WHether to use zsh plugin manager (zinit)";
  };
  config = mkIf cfg.enable {
    modules.shell.env.ZINIT_HOME = "${cpkgs}/share/zinit";
    user.packages = [cpkgs];
  };
}
