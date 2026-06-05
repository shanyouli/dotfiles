{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { config, ... }:
    {
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
          nixfmt = {
            enable = true;
            strict = true;
            width = 100;
          };
          # python
          ruff-format.enable = true;
          ruff-check.enable = true;
          # lua
          stylua.enable = true;

          # bash
          shellcheck.enable = true;
          shfmt = {
            enable = true;
            indent_size = 4;
          };

          # json
          # jsonfmt.enable = true;
          # prettier.enable = true;
          biome = {
            enable = true;
            # Use `check --write` in treefmt so Biome formats files and runs
            # diagnostics in a single pass.
            formatCommand = "check";
            validate.enable = false;
            settings = {
              formatter.lineWidth = 88;
              javascript.formatter.lineWidth = 100;
              json.formatter.enabled = true;
              overrides = [
                {
                  includes = [ "**/config/firefox/chrome/*.css" ];
                  # Firefox chrome CSS relies on Mozilla/XUL-specific selectors,
                  # parser extensions, and intentional !important overrides.
                  # Keep lint enabled, but ignore a small set of incompatible
                  # or intentionally noisy rules for these files only.
                  linter = {
                    enabled = true;
                    rules = {
                      correctness.noUnknownTypeSelector = "off";
                      style.noDescendingSpecificity = "off";
                      complexity.noImportantStyles = "off";
                    };
                  };
                }
                {
                  includes = [ "**/config/zed/settings.json" ];
                  # Zed settings are stored in JSON with comments.
                  json.parser.allowComments = true;
                }
                {
                  includes = [ "**/config/firefox/surfingkeys.js" ];
                  # Surfingkeys config intentionally keeps some bindings and
                  # callback parameters that may look unused to generic JS lint.
                  linter.rules.correctness.noUnusedVariables = "off";
                }
              ];
            };
          };
          # justfile
          just.enable = true;
        };
      };
      formatter = config.treefmt.build.wrapper;
    };
}
