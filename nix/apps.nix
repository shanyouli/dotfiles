{ inputs, self, ... }:
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
          allInputs = builtins.attrNames inputs;
          filterFn =
            v:
            let
              filterList =
                if pkgs.stdenvNoCC.isDarwin then
                  [
                    "nixos-stable"
                    "self"
                  ]
                else
                  [
                    "darwin"
                    "darwin-stable"
                    "self"
                  ];
            in
            builtins.filter (x: !(builtins.elem x filterList)) v;
          stableInputs = filterFn allInputs;
          baseInputs = builtins.filter (
            x:
            !(builtins.elem x [
              "nixos-stable"
              "darwin"
              "darwin-stable"
              "self"
            ])
          ) allInputs;
        in
        my.writeNuScriptBin "update-flake" ''
          use std log
          log info $"The execution file path is ($env.FILE_PWD)/update-flake"
          # nix flake update inputs
          def main [--all(-a), --stable(-s)] {
            if $all {
              log info "update all flake inputs."
              ^nix flake update --commit-lock-file
              return 0
            }
            if $stable {
              log info $"(ansi blue_bold)>>>(ansi reset) update (ansi blue_bold)${pkgs.lib.concatStringsSep " " stableInputs}(ansi reset)"
              ^nix flake update ${pkgs.lib.concatStringsSep " " stableInputs} --commit-lock-file
            } else {
              log info $"(ansi blue_bold)>>>(ansi reset) update (ansi blue_bold)${pkgs.lib.concatStringsSep " " baseInputs}(ansi reset)"
              ^nix flake update ${pkgs.lib.concatStringsSep " " baseInputs} --commit-lock-file
            }
          }
        '';
      apps.buildci.program = my.writeNuScriptBin "buildCI" ''
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
          ["linux", "home", "darwin"]
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
              nix build $"${self}#($flakeType).($host).config.system.build.toplevel" ...$common_options ...$rest
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
