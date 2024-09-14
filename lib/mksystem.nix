{
  lib,
  inputs,
  self,
  ...
}: let
  inherit (inputs) darwin home-manager nixos-stable darwin-stable;
  inherit (self.modules) mapModulesRec';
  inherit (self.utils) relativeToRoot;
  default-darwin-modules = mapModulesRec' (relativeToRoot "modules/darwin") import;
  default-nixos-modules = mapModulesRec' (relativeToRoot "modules/nixos") import;
  default-shared-modules = mapModulesRec' (relativeToRoot "modules/shared") import;
  baseOption = import (relativeToRoot "modules/optionals/os.nix");
in rec {
  mkDarwin = {
    system,
    name,
    darwin-modules ? default-darwin-modules,
    shared-modules ? default-shared-modules,
    overlays,
    genSpecialArgs,
    specialArgs ? (genSpecialArgs system),
    extraModules ? [],
  }:
    darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules =
        [
          baseOption
          ({...}: {
            nixpkgs.pkgs = lib.mkDefault (import darwin-stable {
              inherit system;
              config = {allowUnfree = true;};
              # overlays = overlays;
            });
            # nixpkgs.pkgs = allPkgs."${system}";
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

  mkNixOS = {
    system,
    name,
    nixos-modules ? default-nixos-modules,
    shared-modules ? default-shared-modules,
    overlays,
    genSpecialArgs,
    specialArgs ? (genSpecialArgs system),
    extraModules ? [],
  }:
    nixos-stable.lib.nixosSystem {
      inherit system specialArgs;
      modules =
        [
          baseOption
          ({...}: {
            nixpkgs.pkgs = lib.mkDefault (import nixos-stable {
              inherit system;
              config = {allowUnfree = true;};
            });
            nixpkgs.overlays = overlays;
            networking.hostName = name;
          })
          home-manager.nixosModules.home-manager
        ]
        ++ shared-modules
        ++ nixos-modules
        ++ extraModules;
    };
}
