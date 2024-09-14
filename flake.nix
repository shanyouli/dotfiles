{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "darwin-stable";

    # 需要同步的 flake
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nurpkgs.url = "github:shanyouli/nur-packages/stable";
    nurpkgs.inputs.nixpkgs.follows = "nixpkgs";
    nurpkgs.inputs.nixpkgs-stable.follows = "nixos-stable";
    nurpkgs.inputs.flake-utils.follows = "flake-utils";
    nurpkgs.inputs.flake-compat.follows = "flake-compat";
    nurpkgs.inputs.flake-parts.follows = "flake-parts";

    # nix fmt 进行格式化, 对应配置 ./parts/treefmt.nix
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks-nix.inputs.nixpkgs-stable.follows = "nixos-stable";
    git-hooks-nix.inputs.flake-compat.follows = "flake-compat";
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
          mapLoad = dir: fn: (let
            filterFn = v:
              filterAttrs (name: type:
                (type == "directory" && builtins.pathExists "${builtins.toString ./parts}/${name}/default.nix")
                || (type == "regular" && hasSuffix ".nix" name && name != "default.nix" && !(hasPrefix "_" name)))
              v;
            dirs = mapAttrsToList (k: _: "${dir}/${k}") (filterFn (builtins.readDir dir));
          in
            map fn dirs);
        in
          mapLoad ./parts import;

        perSystem = {system, ...}: {
          legacyPackages.homeConfigurations.test = self.lib.my.mkhome {
            inherit system withSystem self;
            overlays = [self.overlays.python];
            modules = [(self.lib.my.relativeToRoot "hosts/test/home-manager.nix")];
          };
        };

        flake = {
          # homeConfigurations 自定义配置
          # homeConfigurations  = {
          #   "lyeli" = self.lib.my.mkhome {
          #     inherit withSystem self;
          #     system = "x86_64-linux";
          #     modules = [(self.lib.my.relativeToRoot "hosts/test/home-manager.nix")];
          #   };
          # };
          darwinConfigurations = {
            "test@aarch64-darwin" = self.lib.my.mkdarwin {
              system = "aarch64-darwin";
              inherit withSystem self;
              overlays = [self.overlays.python];
              modules = [(self.lib.my.relativeToRoot "hosts/test/home-manager.nix")];
            };
            "test@x86_64-darwin" = self.lib.my.mkdarwin {
              inherit withSystem self;
              system = "x86_64-darwin";
              overlays = [self.overlays.python];
              modules = [(self.lib.my.relativeToRoot "hosts/test/home-manager.nix")];
            };
            "lyeli@aarch64-darwin" = self.lib.my.mkdarwin {
              system = "aarch64-darwin";
              inherit withSystem self;
              overlays = [self.overlays.python];
              name = "home-box";
              modules = [(self.lib.my.relativeToRoot "hosts/homebox.nix")];
            };
          };
          nixosConfigurations = {
            "test@aarch64-linux" = self.lib.my.mknixos {
              inherit withSystem self;
              system = "aarch64-linux";
              overlays = [self.overlays.python];
              modules = [
                (self.lib.my.relativeToRoot "hosts/test/orbstack")
                (self.lib.my.relativeToRoot "hosts/test/home-manager.nix")
              ];
            };
            "test@x86_64-linux" = self.lib.my.mknixos {
              inherit withSystem self;
              overlays = [self.overlays.python];
              modules = [
                (self.lib.my.relativeToRoot "hosts/test/nixos-x86_64")
                (self.lib.my.relativeToRoot "hosts/test/home-manager.nix")
              ];
            };
          };
        };
      }
    );
}
