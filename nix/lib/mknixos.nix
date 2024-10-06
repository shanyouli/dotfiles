{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixos-stable home-manager;
in {
  mknixos = {
    withSystem,
    self,
    # name ? "localhost",
    system ? "x86_64-linux",
    nixpkgs ? null,
    overlays ? [],
    config ? {},
    modules ? [],
  }:
    withSystem system (
      {
        pkgs,
        system,
        my,
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
              inherit self my;
              inherit (self) inputs;
            };
            modules =
              [
                (_: {
                  nixpkgs.pkgs = usePkgs;
                  nixpkgs.overlays = overlays;
                  # networking.hostName = lib.mkDefault name;
                })
                home-manager.nixosModules.home-manager
                self.nixosModules.default
              ]
              ++ modules;
          }
        )
    );
}
