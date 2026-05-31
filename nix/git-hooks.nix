{ inputs, ... }:
{
  imports = [ inputs.git-hooks-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      pre-commit = {
        check.enable = true;
        settings.hooks = {
          block-root-flake-files = {
            enable = true;
            name = "block root flake files";
            language = "system";
            pass_filenames = false;
            always_run = true;
            entry = toString (
              pkgs.writeShellScript "block-root-flake-files" ''
                set -euo pipefail

                staged_files="$(${pkgs.git}/bin/git diff --cached --name-only -- flake.nix flake.lock)"
                if [ -n "$staged_files" ]; then
                  printf '%s\n' "Do not commit root flake link files:"
                  printf '%s\n' "$staged_files"
                  printf '%s\n' "Use: git restore --staged flake.nix flake.lock"
                  exit 1
                fi
              ''
            );
          };

          treefmt = {
            enable = true;
            language = "system";
          };
        };
      };
    };
}
