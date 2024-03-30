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
    programs.nix-index = {
      enable = true;
      package = pkgs.unstable.nix-index-with-db;
    };
  };
}
