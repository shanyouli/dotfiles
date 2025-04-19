{ inputs, ... }:
{
  imports = [ inputs.git-hooks-nix.flakeModule ];
  perSystem.pre-commit = {
    check.enable = true;
    settings.hooks.treefmt.enable = true;
  };
}
