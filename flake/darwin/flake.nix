{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

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

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, self, ... }:
      {
        systems = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        imports = [ ./flake/common.nix ];

        flake.darwinConfigurations = {
          "test@aarch64-darwin" = self.my.mkdarwin {
            system = "aarch64-darwin";
            inherit withSystem self;
            overlays = [ self.overlays.python ];
          };
          "test@x86_64-darwin" = self.my.mkdarwin {
            inherit withSystem self;
            system = "x86_64-darwin";
            overlays = [ self.overlays.python ];
          };
          "lyeli@aarch64-darwin" = self.my.mkdarwin {
            system = "aarch64-darwin";
            inherit withSystem self;
            overlays = [ self.overlays.python ];
            name = "home-box";
            modules = [ (self.my.relativeToRoot "hosts/homebox.nix") ];
          };
        };
      }
    );
}
