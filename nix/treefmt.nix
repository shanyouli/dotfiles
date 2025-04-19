{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];
  perSystem = {config, ...}: {
    treefmt = {
      projectRootFile = "flake.nix";
      settings.global.excludes = [
        "hosts/**/hardware-*.nix"
        "*.gpg"
        "*.lock"
        "orbstack.nix"
      ];

      programs = {
        # nix format
        statix.enable = true; # nix static analysis
        deadnix = {
          no-lambda-arg = true;
          enable = true;
        };
        alejandra.enable = true; # nix fmt tools

        # python
        ruff.enable = true;
        ruff.check = true;
        # lua
        stylua.enable = true;

        # bash
        shellcheck.enable = true;
        shfmt = {
          enable = true;
          indent_size = 4;
        };

        # json
        jsonfmt.enable = true;
        # justfile
        just.enable = true;
      };
    };
    formatter = config.treefmt.build.wrapper;
  };
}
