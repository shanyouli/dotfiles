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
  cfg = cfm.shell.nix-index;
in {
  options.modules.shell.nix-index = {
    enable = mkEnableOption "Whether to nix-index";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.nix-index];
    modules.shell.prevInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
  };
}
