{ self, ... }:
{
  perSystem =
    {
      self',
      my,
      pkgs,
      ...
    }:
    {
      apps.update.program =
        let
          updateScript = pkgs.writeShellScriptBin "update-flake" ''
            set -euo pipefail

            stable_day=false
            if ${pkgs.python3}/bin/python3 - <<'PY'
            from datetime import datetime, timedelta, timezone
            today = datetime.now(timezone.utc).date()
            raise SystemExit(0 if today.weekday() == 5 and (today + timedelta(days=7)).month != today.month else 1)
            PY
            then
              stable_day=true
            fi

            update_inputs() {
              local target="$1"
              shift

              echo "link $target flake"
              ${pkgs.just}/bin/just init "$target"

              if [ "$#" -gt 0 ]; then
                echo "update $target inputs: $*"
                nix flake update "$@"
              fi
            }

            update_inputs linux \
              nixpkgs \
              flake-parts \
              flake-utils \
              flake-compat \
              nurpkgs \
              treefmt-nix \
              git-hooks-nix

            update_inputs darwin \
              nixpkgs \
              flake-parts \
              flake-utils \
              flake-compat \
              nurpkgs \
              treefmt-nix \
              git-hooks-nix \
              mac-app-util

            if [ "$stable_day" = true ]; then
              update_inputs linux nixpkgs-stable home-manager
              update_inputs darwin nixpkgs-stable home-manager darwin
            else
              echo "skip stable inputs; today is not the last Saturday of the month"
            fi

            ${pkgs.git}/bin/git add \
              flake/linux/flake.nix \
              flake/linux/flake.lock \
              flake/darwin/flake.nix \
              flake/darwin/flake.lock

            if ${pkgs.git}/bin/git diff --cached --quiet; then
              echo "no flake input changes"
              exit 0
            fi

            ${pkgs.git}/bin/git commit -m "build(deps): update flake inputs"
          '';
        in
        "${updateScript}/bin/update-flake";
      apps.buildci.program = my.nu.writeNuScriptBin "buildCI" ''
        use std log
        log info $"The script file path is ($env.CURRENT_FILE)"
        let uname_info = uname
        let arch = if (($uname_info | get machine | str downcase) == "arm64") {
          "aarch64"
        } else {
          "x86_64"
        }
        let systemos = if ((uname | get operating-system | str downcase) == "darwin") {
          "darwin"
        } else {
          "linux"
        }
        let common_options = [
          --impure,
          --extra-substituters,
          "https://shanyouli.cachix.org",
          --show-trace,
          -L
        ]
        # ${self} ==> .;
        def "test flake type" [] {
          if $systemos == "darwin" {
            ["darwin", "home"]
          } else {
            ["linux", "home"]
          }
        }
        def "test subcmd" [] {
          ["test", "build", "switch"]
        }
        def --wrapped test [
          flakeType: string@"test flake type", # 默认测试构建类型
          ...rest # 额外参数
        ] {
          let flakeType = if ($flakeType not-in ["linux", "darwin", "home"]) {
                if ($systemos == "darwin") { "darwinConfigurations" } else {"nixosConfigurations"}
            } else {
              match $flakeType {
                "darwin" => "darwinConfigurations",
                "linux" => "nixosConfigurations",
                "home" => "homeConfigurations"
              }
            }
          if ($flakeType == "homeConfigurations") {
            nix run -v --experimental-features "nix-command flakes" --extra-substituters https://shanyouli.cachix.org --impure github:nix-community/home-manager --no-write-lock-file -- build --flake ${self}#test -b backup --show-trace
          } else {
            nix build  $'"${self}#($flakeType).test@($arch)-($systemos).config.system.build.toplevel"' ...$common_options ...$rest
          }
        }
        def --wrapped main [
          subcmd: string@"test subcmd" = "test" # subCommand
          --type: string@"test flake type"
          --host: string
          ...rest
        ] {
          if ($subcmd == "test") {
            if ($type == null) {
            test $systemos ...$rest
            } else {
              log info "good"
              test $type ...$rest
            }
            return 0
          }
          let flakeType = if ($type not-in ["linux", "darwin", "home"]) {
                if ($systemos == "darwin") { "darwinConfigurations" } else {"nixosConfigurations"}
              } else {
                match $type {
                  "darwin" => "darwinConfigurations",
                  "linux" => "nixosConfigurations",
                  "home" => "homeConfigurations"
                }
              }
          let host = if ($host == null) {
              $"($env.USER)@($arch)-($systemos)"
              } else {
                $host
              }
          if ($subcmd == "build") {
            if ($flakeType == "homeConfigurations") {
              nix run -v --experimental-features "nix-command flakes" --extra-substituters https://shanyouli.cachix.org --impure github:nix-community/home-manager --no-write-lock-file -- build --flake $"${self}#($host)" -b backup --show-trace
            } else {
              nix build $"${self}#($flakeType).($host).config.system.build.toplevel" ...$common_options ...$rest
            }
          } else if ($subcmd == "switch") {
            if ($flakeType == "homeConfigurations") {
              nix run -v --experimental-features "nix-command flakes" --extra-substituters https://shanyouli.cachix.org --impure github:nix-community/home-manager --no-write-lock-file -- switch --flake $"${self}#($host)" -b backup --show-trace
            } else {
              log info $"${self}#($flakeType).($host).config.system.build.toplevel" (...$common_options) (...$rest)"
              nix build -v --experimental-features "nix-command flakes" $"${self}#($flakeType).($host).config.system.build.toplevel" ...$common_options ...$rest
              match $flakeType {
                "darwinConfigurations" => { ./result/sw/bin/darwin-rebuild switch --flake $"${self}#($host)" --impure },
                "nixosConfigurations" => { ./result/sw/bin/nixos-rebuild switch --flake $"${self}#($host)" --impure },
              }
            }
          }
        }
      '';
      apps.checks =
        let
          drv =
            let
              bin = pkgs.writeShellScriptBin "drv-checkos" ''
                echo check ok
              '';
            in
            pkgs.runCommand "checks-combined"
              {
                checksss = builtins.attrValues self'.checks;
                buildInputs = [ bin ];
              }
              ''
                mkdir -p $out/bin
                cp ${bin} $out/bin/checks-combined
              '';
        in
        {
          type = "app";
          program = "${drv}/bin/drv-checkos";
        };
    };
}
