{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
  };

  outputs = inputs @ {self, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      imports = [
        ./parts/lib
        ./parts/vars
        ./parts/overlays
        ./parts/pkgs
        ./parts/mkhome.nix
        ./parts/home-modules.nix
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }:{
      };

      flake = {
        # All home-manager configurations are kept here.
        # homeModules.default = {pkgs, ...}: {
        #   imports = [];
        #   programs = {
        #     git.enable = true;
        #     starship.enable = true;
        #     bash.enable = true;
        #   };
        # };
      };
    };
}
