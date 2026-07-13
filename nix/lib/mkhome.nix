{ inputs, lib, ... }:
let
  inherit (inputs) home-manager;

  # mkUsePkgs is the shared nixpkgs-instance resolver for host factories.
  # When an explicit nixpkgs or config is supplied, re-import on demand;
  # otherwise reuse the perSystem-injected pkgs.
  mkUsePkgs =
    {
      system,
      self,
      pkgs,
      overlays ? [ ],
      config ? { },
      nixpkgs ? null,
      defaultNixpkgs,
    }:
    let
      isUpPkgs = !(builtins.isNull nixpkgs);
      mypkgs = if isUpPkgs then nixpkgs else defaultNixpkgs;
    in
    if (isUpPkgs || config != { }) then
      import mypkgs (
        lib.recursiveUpdate {
          inherit system;
          overlays = [ self.overlay ] ++ overlays;
          config.allowUnfree = true;
        } { inherit config; }
      )
    else
      pkgs;
in
{
  inherit mkUsePkgs;

  mkhome =
    {
      withSystem,
      self,
      system ? "x86_64-linux",
      nixpkgs ? null,
      overlays ? [ ],
      config ? { },
      modules ? [ ],
      name ? "test",
    }:
    withSystem system (
      {
        pkgs,
        system,
        my,
        ...
      }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = my.mkUsePkgs {
          inherit
            system
            self
            overlays
            config
            nixpkgs
            pkgs
            ;
          defaultNixpkgs = inputs.nixpkgs-stable;
        };
        extraSpecialArgs = {
          inherit self my;
          inherit (self) inputs;
        };
        modules = [
          (_: { nixpkgs.overlays = overlays; })
          self.homeModules.default
        ]
        ++ lib.optionals (name == "test") [ (my.relativeToRoot "hosts/test/home-manager.nix") ]
        ++ modules;
      }
    );
}
