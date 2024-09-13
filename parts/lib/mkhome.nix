{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) darwin-stable nixos-stable home-manager;
in {
  mkhome = {
    withSystem,
    self,
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
        home-manager.lib.homeManagerConfiguration {
          pkgs = let
            isUpPkgs = ! (builtins.isNull nixpkgs);
            mypkgs =
              if isUpPkgs
              then nixpkgs
              else
                (
                  if pkgs.stdaenvNoCC.isDarwin
                  then darwin-stable
                  else nixos-stable
                );
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
          extraSpecialArgs = {
            inherit self myvars;
            inherit (self) inputs lib;
          };
          modules =
            [
              ({...}: {
                nixpkgs.overlays = overlays;
              })
            ]
            ++ self.homeModules.default
            ++ modules;
        }
    );
}
