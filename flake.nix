{
  # the nixConfig here only affects the flake itself, not the system configuration!
  # nixConfig = {
  #   # override the default substituters
  #   substituters = [
  #     # cache mirror located in China
  #     # status: https://mirror.sjtu.edu.cn/
  #     # "https://mirror.sjtu.edu.cn/nix-channels/store"
  #     # status: https://mirrors.ustc.edu.cn/status/
  #     "https://mirrors.ustc.edu.cn/nix-channels/store"

  #     "https://cache.nixos.org"

  #     # nix community's cache server
  #     "https://nix-community.cachix.org"
  #     "https://shanyouli.cachix.org"
  #   ];
  #   trusted-public-keys = [
  #     # nix community's cache server public key
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #     "shanyouli.cachix.org-1:19ndCE7zQfn5vIVLbBZk6XG0D7Ago7oRNNgIRV/Oabw="
  #   ];
  # };
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
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
        treefmt-nix.follows = "treefmt-nix";
        git-hooks-nix.follows = "git-hooks-nix";
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
        flake-compat.follows = "flake-compat";
      };
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs @ {flake-parts, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      {
        withSystem,
        self,
        ...
      }: {
        # debug = true;
        systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
        imports = let
          inherit (inputs.nixpkgs.lib) filterAttrs mapAttrsToList hasSuffix hasPrefix;
          filterFn = path:
            filterAttrs (name: type:
              (type == "directory" && (builtins.pathExists "${path}/${name}/default.nix"))
              || (type == "regular" && hasSuffix ".nix" name && name != "default.nix" && !(hasPrefix "_" name)))
            (builtins.readDir path);
          fn = path: mapAttrsToList (k: _: "${path}/${k}") (filterFn path);
        in
          fn (builtins.toString ./nix);

        perSystem = {system, ...}: {
          legacyPackages.homeConfigurations.test = self.my.mkhome {
            inherit system withSystem self;
            overlays = [self.overlays.python];
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
            };
            "test@x86_64-darwin" = self.my.mkdarwin {
              inherit withSystem self;
              system = "x86_64-darwin";
              overlays = [self.overlays.python];
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
            };
            "test@x86_64-linux" = self.my.mknixos {
              inherit withSystem self;
              overlays = [self.overlays.python];
            };
          };
        };
      }
    );
}
