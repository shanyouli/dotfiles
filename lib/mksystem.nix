{
  lib,
  inputs,
  self,
  ...
}: let
  inherit (inputs) darwin darwin-stable home-manager nixos-stable;
  inherit (self.modules) mapModulesRec';
  inherit (self.utils) relativeToRoot;
  default-darwin-modules = mapModulesRec' (relativeToRoot "modules/darwin") import;
  default-nixos-modules = mapModulesRec' (relativeToRoot "modules/nixos") import;
  default-shared-modules = mapModulesRec' (relativeToRoot "modules/shared") import;
in rec {
  mkDarwin = {
    system,
    name,
    darwin-modules ? default-darwin-modules,
    shared-modules ? default-shared-modules,
    myvars ? (import (relativeToRoot "vars") {inherit lib system;}),
    overlays,
    genSpecialArgs,
    specialArgs ? (genSpecialArgs system),
    extraModules ? [],
  }: {
    "${myvars.user}@${system}" = darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules =
        [
          ({lib, ...}: {
            nixpkgs.pkgs = lib.mkDefault (import darwin-stable {
              inherit system;
            });
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = overlays;
            networking.hostName = name;
          })
          home-manager.darwinModules.home-manager
        ]
        ++ shared-modules
        ++ darwin-modules
        ++ extraModules;
    };
  };

  mkNixOS = {
    system,
    name,
    nixos-modules ? default-nixos-modules,
    shared-modules ? default-shared-modules,
    myvars ? (import (relativeToRoot "vars") {inherit lib system;}),
    overlays,
    genSpecialArgs,
    specialArgs ? (genSpecialArgs system),
    extraModules ? [],
  }: {
    "${myvars.user}@${system}" = nixos-stable.lib.nixosSystem {
      inherit system specialArgs;
      modules =
        [
          ({lib, ...}: {
            nixpkgs.pkgs = lib.mkDefault (import nixos-stable {
              inherit system;
            });
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = overlays;
            networking.hostName = name;
          })
          home-manager.darwinModules.home-manager
        ]
        ++ shared-modules
        ++ nixos-modules
        ++ extraModules;
    };
  };
}
