{inputs, ...}: {
  imports = [inputs.git-hooks-nix.flakeModule];
  preSystem.pre-commit = {
    check.enable = true;
    settings.excludes = ["hosts/**/hardware-*.nix$"];
    settings.hooks = {
      alejandra.enable = true;
      deadnix.enable = true;
      ruff.enable = true;
      ruff.check = true;
      # lua
      stylua.enable = true;

      # bash
      shellcheck.enable = false;
      shfmt.enable = true;

      # json
      jsonfmt.enable = true;
    }
  }
}
