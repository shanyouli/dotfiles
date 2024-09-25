{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "darwin-stable";
    };

    # 需要同步的 flake
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nurpkgs = {
      url = "github:shanyouli/nur-packages/stable";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixos-stable";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
      };
    };

    # nix fmt 进行格式化, 对应配置 ./parts/treefmt.nix
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixos-stable";
        flake-compat.follows = "flake-compat";
      };
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      {
        withSystem,
        self,
        ...
      }: {
        debug = true;
        systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
        imports = let
          inherit (inputs.nixpkgs.lib) filterAttrs mapAttrsToList hasSuffix hasPrefix;
          filterFn = v:
            filterAttrs (name: type:
              (type == "directory" && builtins.pathExists ./parts/${name}/default.nix)
              || (type == "regular" && hasSuffix ".nix" name && name != "default.nix" && !(hasPrefix "_" name)))
            v;
        in
          mapAttrsToList (k: _: ./parts/${k}) (filterFn (builtins.readDir ./parts));

        perSystem = {system, ...}: {
          legacyPackages.homeConfigurations.test = self.my.mkhome {
            inherit system withSystem self;
            overlays = [self.overlays.python];
            modules = [(self.my.relativeToRoot "hosts/test/home-manager.nix")];
          };
        };

        flake = {
          # homeConfigurations 自定义配置
          # homeConfigurations  = {
          #   "lyeli" = self.my.mkhome {
          #     inherit withSystem self;
          #     system = "x86_64-linux";
          #     modules = [(self.my.relativeToRoot "hosts/test/home-manager.nix")];
          #   };
          # };
          darwinConfigurations = {
            "test@aarch64-darwin" = self.my.mkdarwin {
              system = "aarch64-darwin";
              inherit withSystem self;
              overlays = [self.overlays.python];
              modules = [(self.my.relativeToRoot "hosts/test/home-manager.nix")];
            };
            "test@x86_64-darwin" = self.my.mkdarwin {
              inherit withSystem self;
              system = "x86_64-darwin";
              overlays = [self.overlays.python];
              modules = [(self.my.relativeToRoot "hosts/test/home-manager.nix")];
            };
            "lyeli@aarch64-darwin" = self.my.mkdarwin {
              system = "aarch64-darwin";
              inherit withSystem self;
              overlays = [self.overlays.python];
              name = "home-box";
              modules = [(self.my.relativeToRoot "hosts/homebox.nix")];
            };
          };
          nixosConfigurations = {
            "test@aarch64-linux" = self.my.mknixos {
              inherit withSystem self;
              system = "aarch64-linux";
              overlays = [self.overlays.python];
              modules = [
                (self.my.relativeToRoot "hosts/test/orbstack")
              ];
            };
            "test@x86_64-linux" = self.my.mknixos {
              inherit withSystem self;
              overlays = [self.overlays.python];
              modules = [
                (self.my.relativeToRoot "hosts/test/nixos-x86_64")
              ];
            };
          };
        };
      }
    );
}
