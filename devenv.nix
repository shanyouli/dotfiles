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
    hooks = {
      shellcheck.enable = true;
      alejandra.enable = true;
      deadnix.enable = true;
      shfmt.enable = false;
      stylua.enable = true;
      ruff.enable = true;
    };

    settings = {
      deadnix.edit = true;
      deadnix.noLambdaArg = true;
      alejandra.exclude = ["generated.nix"];
    };
  };
}
