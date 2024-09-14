{inputs, ...}: let
  inherit (inputs) nixos-stable home-manager;
in {
  mknixos = {
    withSystem,
    self,
    name ? "localhost",
    system ? "x86_64-linux",
    nixpkgs ? null,
    overlays ? [],
    config ? {},
    modules ? [],
  }:
    withSystem system (
      {
        lib,
        pkgs,
        system,
        myvars,
        ...
      }:
        nixos-stable.lib.nixosSystem (
          let
            usePkgs = let
              isUpPkgs = ! (builtins.isNull nixpkgs);
              mypkgs =
                if isUpPkgs
                then nixpkgs
                else nixos-stable;
            in
              if (isUpPkgs || config != {})
              then
                import mypkgs (lib.recursiveUpdate {
                    inherit system;
                    overlays = [self.overlay.default] ++ overlays;
                    config.allowUnfree = true;
                  } {
                    inherit config;
                  })
              else pkgs;
          in {
            specialArgs = {
              inherit self myvars;
              inherit (self) inputs lib;
            };
            modules =
              [
                ({...}: {
                  nixpkgs.pkgs = usePkgs;
                  nixpkgs.overlays = overlays;
                  networking.hostName = name;
                })
                home-manager.nixosModules.home-manager
              ]
              ++ self.nixosModules.default
              ++ modules;
          }
        )
    );
}
