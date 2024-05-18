{
  lib,
  config,
  options,
  pkgs,
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
    programs.nix-index = {
      enable = true;
      package = pkgs.unstable.my.nix-index;
      # package = inputs.nurpkgs.currentSystem.packages.nix-index;
    };
  };
}
