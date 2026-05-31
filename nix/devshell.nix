{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        name = "Shanyou Li";
        meta.description = "nix development environment";
        inputsFrom = lib.optionals (inputs ? treefmt-nix) [ config.treefmt.build.programs ];
        nativeBuildInputs =
          let
            pre-commitPackags =
              if (inputs ? git-hooks-nix) then
                with config.pre-commit; settings.enabledPackages ++ [ settings.package ]
              else
                [ ];
          in
          pre-commitPackags;
        # ++ lib.optionals (inputs ? treefmt-nix) [config.treefmt.build.wrapper];
        # packages = [pkgs.cachix];
        packages = [
          pkgs.cachix
          pkgs.just
          pkgs.nixd
        ];
        shellHook = ''
          FLAKE_ROOT=$(${lib.getExe pkgs.git} rev-parse --show-toplevel)
        ''
        + lib.optionalString (inputs ? treefmt-nix) ''
          SYMLINK_SOURCE_PATH="${config.treefmt.build.configFile}"
          SYMLINK_TARGET_PATH="$FLAKE_ROOT/.treefmt.toml"

          if [[ -e "$SYMLINK_TARGET_PATH" && ! -L "$SYMLINK_TARGET_PATH" ]]; then
            echo "treefmt-nix: Error: Target exists but is not a symlink."
            exit 1
          fi

          if [[ -L "$SYMLINK_TARGET_PATH" ]]; then
            if [[ "$(readlink "$SYMLINK_TARGET_PATH")" != "$SYMLINK_SOURCE_PATH" ]]; then
              echo "treefmt-nix: Removing existing symlink"
              unlink "$SYMLINK_TARGET_PATH"
            else
              SYMLINK_SOURCE_PATH=""
            fi
          fi

          if [[ -n "$SYMLINK_SOURCE_PATH" ]]; then
            nix-store --add-root "$SYMLINK_TARGET_PATH" --indirect --realise "$SYMLINK_SOURCE_PATH"
            echo "treefmt-nix: Created symlink successfully"
          fi
        ''
        + lib.optionalString (inputs ? git-hooks-nix) config.pre-commit.settings.installationScript
        + ''
          git config --local --unset core.hooksPath >/dev/null 2>&1 || true
          hook_source="$FLAKE_ROOT/bin/git-hook-flake-root-link"
          if [ -x "$hook_source" ]; then
            for hook in post-commit post-checkout post-merge; do
              cp "$hook_source" "$FLAKE_ROOT/.git/hooks/$hook"
              chmod +x "$FLAKE_ROOT/.git/hooks/$hook"
            done
            git update-index --skip-worktree flake.nix flake.lock
          fi
        '';
      };
    };
}
