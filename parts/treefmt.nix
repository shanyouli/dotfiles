{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];
  perSystem = {config, ...}: {
    treefmt = {
      projectRootFile = "flake.nix";
      settings.global.excludes = [
        "hosts/**/hardware-*.nix"
        "*.gpg"
        "*.lock"
      ];

      programs = {
        # nix format
        alejandra.enable = true;
        deadnix.enable = true;
        deadnix.settings.edit = true;
        deadnix.settings.noLambdaArg = true;

        # python
        ruff.enable = true;
        ruff.check = true;
        # lua
        stylua.enable = true;

        # bash
        shellcheck.enable = true;
        shfmt.enable = true;
      };
    };
    formatter = config.treefmt.build.wrapper;
  };
}
