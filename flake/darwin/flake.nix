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
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, self, ... }:
      let
        inherit (inputs) home-manager darwin nixpkgs-stable;
        lib = inputs.nixpkgs.lib;

        # mkdarwin builds a nix-darwin system configuration. It is inlined
        # here (rather than selected at runtime via a platform guard) so the
        # darwin flake always exposes it regardless of evaluation order.
        mkdarwin =
          {
            name ? "localhost",
            system ? "aarch64-darwin",
            nixpkgs ? null,
            overlays ? [ ],
            config ? { },
            modules ? [ ],
          }:
          withSystem system (
            {
              pkgs,
              system,
              my,
              ...
            }:
            darwin.lib.darwinSystem (
              let
                usePkgs = my.mkUsePkgs {
                  inherit
                    system
                    self
                    overlays
                    config
                    nixpkgs
                    pkgs
                    ;
                  defaultNixpkgs = nixpkgs-stable;
                };
              in
              {
                specialArgs = {
                  inherit self my;
                  inherit (self) inputs;
                };
                modules = [
                  (_: {
                    nixpkgs.pkgs = usePkgs;
                    nixpkgs.overlays = overlays;
                    networking.hostName = name;
                  })
                  home-manager.darwinModules.home-manager
                  self.darwinModules.default
                ]
                ++ lib.optionals (name == "localhost") [ (my.relativeToRoot "hosts/test/darwin.nix") ]
                ++ modules;
              }
            )
          );
      in
      {
        systems = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        imports = [ ./flake/common.nix ];

        flake.darwinConfigurations = {
          "test@aarch64-darwin" = mkdarwin {
            system = "aarch64-darwin";
            overlays = [ self.overlays.python ];
          };
          "test@x86_64-darwin" = mkdarwin {
            system = "x86_64-darwin";
            overlays = [ self.overlays.python ];
          };
          "lyeli@aarch64-darwin" = mkdarwin {
            system = "aarch64-darwin";
            overlays = [ self.overlays.python ];
            name = "home-box";
            modules = [ (self.my.relativeToRoot "hosts/homebox.nix") ];
          };
        };
      }
    );
}
