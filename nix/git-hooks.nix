{inputs, ...}: {
  imports = [inputs.git-hooks-nix.flakeModule];
  perSystem.pre-commit = {
    check.enable = true;
    settings.excludes = ["^hosts/.*/hardware-.*\.nix$" ".*orbstack\.nix$"];
    settings.hooks = {
      alejandra.enable = true;
      deadnix = {
        enable = true;
        settings = {
          edit = true;
          noLambdaArg = true;
        };
      };
      statix = {
        enable = true;
        settings.ignore = ["orbstack.nix"];
      };

      ruff.enable = true;
      # ruff.check = true;
      # lua
      stylua.enable = true;

      # bash
      shellcheck.enable = false;
      shfmt = {
        enable = true;
        args = ["-i" "4"];
        exclude_types = ["zsh"];
      };

      # json
      # jsonfmt.enable = true;
    };
  };
}
