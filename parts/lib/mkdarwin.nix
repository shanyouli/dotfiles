{inputs, ...}: let
  inherit (inputs) darwin-stable home-manager darwin nh_darwin;
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
                (_: {
                  nixpkgs.pkgs = usePkgs;
                  nixpkgs.overlays = overlays;
                  networking.hostName = name;
                })
                home-manager.darwinModules.home-manager
                nh_darwin.nixDarwinModules.prebuiltin
                # inputs.nh_darwin.nixDarwinModules.default
                self.homeModules.common
                self.darwinModules.default
              ]
              ++ modules;
          }
        )
    );
}
