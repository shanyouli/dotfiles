{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      name = "Shanyou Li";
      meta.description = "nix development environment";
      inputsFrom = lib.optionals (inputs ? treefmt-nix) [config.treefmt.build.programs];
      nativeBuildInputs = let
        pre-commitPackags =
          if (inputs ? git-hooks-nix)
          then with config.pre-commit; settings.enabledPackages ++ [settings.package]
          else [];
      in
        pre-commitPackags;
      # packages = [pkgs.cachix];
      packages = [pkgs.cachix pkgs.just];
      shellHook = "" + lib.optionalString (inputs ? git-hooks-nix) config.pre-commit.settings.installationScript;
    };
  };
}
