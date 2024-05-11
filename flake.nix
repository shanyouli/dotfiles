{
  description = "nix system configurations";

  inputs = {
    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixos-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # shell stuff
    flake-utils.url = "github:numtide/flake-utils";

    devenv.url = "github:cachix/devenv/latest";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    nurpkgs.url = "github:shanyouli/nur-packages";
    nurpkgs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    darwin,
    home-manager,
    flake-utils,
    devenv,
    darwin-stable,
    nixos-stable,
    ...
  }: let
    inherit (flake-utils.lib) eachSystemMap;
    inherit (lib) attrValues;
    inherit (lib.my) defaultSystems mkPkgs mkPkg;

    # with overlays and any extraModules applied
    lib = nixpkgs.lib.extend (self: super: {
      my = import ./lib {
        inherit inputs;
        lib = self;
      };
    });

    allPkgs = mkPkgs {
      nixpkgs = [nixos-stable darwin-stable];
      cfg = {allowUnfree = true;};
      overlays = self.overlays // {};
    };
    baseOverlays = {
      nurpkgs = inputs.nurpkgs.overlays.default;
    };
  in {
    lib = lib.my;
    checks =
      {}
      // (lib.my.mkChecks {
        inherit self;
        arch = "aarch64";
        os = "darwin";
      })
      // (lib.my.mkChecks {
        inherit self;
        arch = "x86_64";
        os = "linux";
        username = "shanyouli";
      })
      // (lib.my.mkChecks {
        inherit self;
        arch = "x86_64";
        os = "darwin";
      })
      // (lib.my.mkChecks {
        inherit self;
        arch = "aarch64";
        os = "linux";
      });

    darwinConfigurations = {
      Lye-MAC = lib.my.mkSystem {
        name = "home-box";
        system = "aarch64-darwin";
        os = inputs.darwin;
        allPkgs = allPkgs;
        baseModules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = builtins.attrValues self.overlays;
          }
          home-manager.darwinModules.home-manager
        ];
        extraModules = [./hosts/homebox.nix];
        specialArgs = {inherit inputs self nixpkgs lib;};
      };
      "lyeli@aarch64-darwin" = lib.my.mkSystem {
        name = "home-box";
        system = "aarch64-darwin";
        os = inputs.darwin;
        allPkgs = allPkgs;
        baseModules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = builtins.attrValues self.overlays;
          }
          home-manager.darwinModules.home-manager
        ];
        extraModules = [./hosts/homebox.nix];
        specialArgs = {inherit inputs self nixpkgs lib;};
      };
      "lyeli@x86_64-darwin" = lib.my.mkSystem {
        name = "home-box";
        os = inputs.darwin;
        allPkgs = allPkgs;
        system = "x86_64-darwin";
        baseModules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = builtins.attrValues self.overlays;
          }
          home-manager.darwinModules.home-manager
        ];
        extraModules = [./hosts/test.nix];
        specialArgs = {inherit inputs self nixpkgs lib;};
      };
    };

    nixosConfigurations = {
      "shanyouli@x86_64-linux" = lib.my.mkSystem {
        name = "nixos-work";
        os = inputs.nixos-stable;
        system = "x86_64-linux";
        allPkgs = allPkgs;
        extraModules = [./hosts/linux-test];
        baseModules = [
          home-manager.nixosModules.home-manager
        ];
        specialArgs = {inherit inputs nixpkgs lib self;};
      };
      "lyeli@aarch64-linux" = lib.my.mkSystem {
        name = "nixos";
        os = inputs.nixos-stable;
        system = "aarch64-linux";
        allPkgs = allPkgs;
        extraModules = [./hosts/orbvm];
        baseModules = [
          home-manager.nixosModules.home-manager
        ];
        specialArgs = {inherit inputs nixpkgs lib self;};
      };
    };

    devShells = eachSystemMap defaultSystems (system: let
      pkgs = allPkgs."${system}";
      # pkgs = mkPkg {
      #   inherit system;
      #   nixpkgs = inputs.nixpkgs;
      #   overlays = self.overlays;
      # };
    in {
      default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [(import ./devenv.nix)];
      };
    });
    # packages = lib.my.withDefaultSystems (system: let
    #   pkgs = allPkgs."${system}";
    # in
    #   (this.packages pkgs.stable)
    #   // {
    #     # devenv = inputs.devenv.defaultPackage.${system};
    #   });

    apps = lib.my.withDefaultSystems (system: let
      pkgs = allPkgs."${system}";
    in rec {
      # sd = {
      #   type = "app";
      #   program = "${self.packages.${system}.sd}/bin/sd";
      # };
      # 加载配置, nix run .#repl
      # @see https://github.com/NixOS/nix/issues/3803#issuecomment-748612294
      repl = flake-utils.lib.mkApp {
        drv = pkgs.writeScriptBin "repl" ''
          confnix=$(mktemp)
          echo "import <nixpkgs> {} // (builtins.getFlake (toString $(git rev-parse --show-toplevel)))" >$confnix
          trap "rm $confnix" EXIT
          nix repl --file $confnix
        '';
      };
      # Since the `nix flake check` command is currently unable to check only the current operating system
      # @see https://github.com/NixOS/nix/issues/4265
      checks = flake-utils.lib.mkApp {
        drv = let
          bin = pkgs.writeScript "checkok" ''
            #! ${pkgs.lib.getExe pkgs.bash}
            echo check ok
          '';
        in
          pkgs.runCommand "checks-combined" {
            checksss = builtins.attrValues self.checks.${system};
            buildInputs = [bin];
          } ''
            mkdir -p $out/bin
            cp ${bin} $out/bin/checks-combined
          '';
      };
      default = repl;
    });

    overlays = {
      channels = final: prev: {
        # expose other channels via overlays
        unstable = mkPkg {
          inherit nixpkgs;
          system = prev.system;
          cfg = {allowUnfree = true;};
          overlays = baseOverlays;
          extraOverlays = [
            (ffinal: pprev: {
              devenv = inputs.devenv.defaultPackage.${pprev.system};
            })
          ];
        };
      };
    };
  };
}
