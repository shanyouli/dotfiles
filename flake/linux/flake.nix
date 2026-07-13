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
      let
        inherit (inputs) home-manager nixpkgs-stable;
        lib = inputs.nixpkgs.lib;

        # mknixos builds a NixOS system configuration. It is inlined here
        # (rather than selected at runtime via a platform guard) so the linux
        # flake always exposes it regardless of evaluation order.
        mknixos =
          {
            name ? "localhost",
            system ? "x86_64-linux",
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
            inputs.nixpkgs-stable.lib.nixosSystem (
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
                modules =
                  let
                    base =
                      if
                        builtins.elem name [
                          "localhost"
                          "test"
                        ]
                      then
                        if system == "x86_64-linux" then
                          [ (my.relativeToRoot "hosts/test/nixos-x86_64") ]
                        else
                          [ (my.relativeToRoot "hosts/test/nixos-aarch64") ]
                      else if (lib.pathExists (my.relativeToRoot "hosts/${name}")) then
                        [ (my.relativeToRoot "hosts/${name}") ]
                      else if (lib.pathExists (my.relativeToRoot "hosts/${name}.nix")) then
                        [ (my.relativeToRoot "hosts/${name}.nix") ]
                      else
                        [ ];
                  in
                  [
                    (_: {
                      nixpkgs.pkgs = usePkgs;
                      nixpkgs.overlays = overlays;
                      # networking.hostName = lib.mkDefault name;
                    })
                    home-manager.nixosModules.home-manager
                    self.nixosModules.default
                  ]
                  ++ base
                  ++ modules;
              }
            )
          );
      in
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = [ ./flake/common.nix ];

        flake.nixosConfigurations = {
          "test@aarch64-linux" = mknixos {
            system = "aarch64-linux";
            overlays = [ self.overlays.python ];
          };
          "test@x86_64-linux" = mknixos { overlays = [ self.overlays.python ]; };
        };
      }
    );
}
