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
