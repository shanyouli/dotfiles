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
    emacs-overlay.url = "github:nix-community/emacs-overlay/master";
    # @see https://github.com/nix-community/emacs-overlay/issues/275
    # emacs-src.url = "github:emacs-mirror/emacs/emacs-29";
    # emacs-src.flake = false;

    # shell stuff
    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv/latest";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
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
    nix-index-database,
    ...
  }: let
    inherit (flake-utils.lib) eachSystemMap;
    inherit (lib) attrValues;
    inherit (lib.my) defaultSystems mkPkgs mkPkg;
    allPkgs = mkPkgs {
      nixpkgs = [nixos-stable darwin-stable];
      cfg = {allowUnfree = true;};
      overlays = self.overlays // {};
    };

    # with overlays and any extraModules applied
    lib = nixpkgs.lib.extend (self: super: {
      my = import ./lib {
        inherit inputs;
        lib = self;
      };
    });
    this = import ./packages;
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
      });

    darwinConfigurations = {
      Lye-MAC = lib.my.mkDarwinConfig {
        name = "home-box";
        system = "aarch64-darwin";
        darwin = inputs.darwin;
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
      "lyeli@aarch64-darwin" = lib.my.mkDarwinConfig {
        name = "home-box";
        system = "aarch64-darwin";
        darwin = inputs.darwin;
        allPkgs = allPkgs;
        baseModules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = builtins.attrValues self.overlays;
          }
          nix-index-database.darwinModules.nix-index
          home-manager.darwinModules.home-manager
        ];
        extraModules = [./hosts/homebox.nix];
        specialArgs = {inherit inputs self nixpkgs lib;};
      };
      "lyeli@x86_64-darwin" = lib.my.mkDarwinConfig {
        name = "home-box";
        darwin = inputs.darwin;
        allPkgs = allPkgs;
        system = "x86_64-darwin";
        baseModules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = builtins.attrValues self.overlays;
          }
          nix-index-database.darwinModules.nix-index
          home-manager.darwinModules.home-manager
        ];
        extraModules = [./hosts/test.nix];
        specialArgs = {inherit inputs self nixpkgs lib;};
      };
    };

    nixosConfigurations = {
      "shanyouli@x86_64-linux" = lib.my.mkNixosConfig {
        name = "nixos-work";
        nixos = inputs.nixos-stable;
        allPkgs = allPkgs;
        extraModules = [
          ./modules/hardware/phil.nix
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t460s
          # ./host/personal.nix
        ];
        baseModules = [
          home-manager.nixosModules.home-manager
          nix-index-database.nixosModules.nix-index
        ];
        specialArgs = {inherit inputs nixpkgs lib self;};
      };
    };

    devShells = eachSystemMap defaultSystems (system: let
      pkgs = mkPkg {
        inherit system;
        nixpkgs = inputs.nixpkgs;
        overlays = self.overlays;
      };
    in {
      default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [(import ./devenv.nix)];
      };
    });
    packages = lib.my.withDefaultSystems (system: let
      pkgs = allPkgs."${system}";
    in
      (this.packages pkgs)
      // {
        # devenv = inputs.devenv.defaultPackage.${system};
      });

    apps = lib.my.withDefaultSystems (system: let
      pkgs = allPkgs."${system}";
    in rec {
      sysdo = {
        type = "app";
        program = "${self.packages.${system}.sysdo}/bin/sysdo";
      };
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
      update = flake-utils.lib.mkApp {
        drv = let
          buildPath = pkgs.buildEnv {
            name = "home-manager-applications";
            paths = with pkgs; [nvfetcher jq curl];
            pathsToLink = "/bin";
          };
        in
          pkgs.writeScriptBin "repl" ''
            #! ${pkgs.lib.getExe pkgs.bash}
            PATH=$PATH:${buildPath}/bin
            keys_args=""
            echo $HOME
            [[ -f $HOME/.config/nvfetcher.toml ]] && keys_args="-k $HOME/.config/nvfetcher.toml"
            [[ -f ./secrets.toml ]] && keys_args="-k ./secrets.toml"
            nvfetcher $keys_args
            echo update firefox ....
            bash packages/darwinApp/firefox/update.sh
          '';
      };
      default = sysdo;
    });

    overlays = {
      channels = final: prev: {
        # expose other channels via overlays
        unstable = mkPkg {
          system = prev.system;
          cfg = {allowUnfree = true;};
          nixpkgs = inputs.nixpkgs;
        };
        devenv = inputs.devenv.defaultPackage.${prev.system};
      };
      python = (import ./packages).overlay;

      nur = inputs.nur.overlay;
    };
  };
}
