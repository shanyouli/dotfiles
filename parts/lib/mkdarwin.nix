{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) darwin-stable nixos-stable home-manager darwin;
in {
  mkdarwin = {
    withSystem,
    self,
    name ? "localhost",
    system ? "aarch64-darwin",
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
        darwin.lib.darwinSystem (
          let
            usePkgs = let
              isUpPkgs = ! (builtins.isNull nixpkgs);
              mypkgs =
                if isUpPkgs
                then nixpkgs
                else darwin-stable;
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
                home-manager.darwinModules.home-manager
              ]
              ++ self.darwinModules.default
              ++ modules;
          }
        )
    );
}
