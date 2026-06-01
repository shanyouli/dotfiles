{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nurpkgs = {
      url = "github:shanyouli/nur-packages/stable";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        git-hooks-nix.follows = "git-hooks-nix";
      };
    };

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
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, self, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = [ ./flake/common.nix ];

        flake.nixosConfigurations = {
          "test@aarch64-linux" = self.my.mknixos {
            inherit withSystem self;
            system = "aarch64-linux";
            overlays = [ self.overlays.python ];
          };
          "test@x86_64-linux" = self.my.mknixos {
            inherit withSystem self;
            overlays = [ self.overlays.python ];
          };
        };
      }
    );
}
