{
  inputs,
  pkgs,
  lib,
  ...
}: {
  packages = [
    pkgs.nil
    (inputs.treefmt-nix.lib.mkWrapper pkgs (import ./treefmt.nix))
  ];

  pre-commit = {
    excludes = ["generated.nix"];
    hooks = {
      shellcheck.enable = true;
      alejandra.enable = true;
      deadnix.enable = true;
      shfmt.enable = false;
      stylua.enable = true;
      ruff.enable = true;

      deadnix.settings.edit = true;
      deadnix.settings.noLambdaArg = true;
    };
  };
}
