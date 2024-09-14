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
        statix.enable = true; # nix static analysis
        deadnix.enable = true; # find dead nix code
        alejandra.enable = true; # nix fmt tools

        # python
        ruff.enable = true;
        ruff.check = true;
        # lua
        stylua.enable = true;

        # bash
        shellcheck.enable = false;
        shfmt.enable = true;

        # json
        jsonfmt.enable = true;
        # justfile
        just.enable = true;
      };
    };
    formatter = config.treefmt.build.wrapper;
  };
}
