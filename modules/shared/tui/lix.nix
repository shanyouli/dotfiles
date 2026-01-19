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
  cfp = config.modules.tui;
  cfg = cfp.lix;
in
{
  options.modules.tui.lix = {
    enable = mkEnableOption "Whether to use lix";
    package = mkPackageOption pkgs.lixPackageSets.stable "lix" { };
  };
  config = mkIf cfg.enable {
    nix.package = mkForce cfg.package;
    nixpkgs.overlays = [
      (final: prev: {
        inherit (prev.lixPackageSets.stable)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena
          ;
        cached-nix-shell = prev.cached-nix-shell.override { nix = config.modules.tui.lix.package; };
      })
    ];
  };
}
