{ inputs, lib, ... }:
let
  inherit (inputs) home-manager;
in
{
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
      let
        stableNixpkgs = my.nixpkgsStable system;
      in
      home-manager.lib.homeManagerConfiguration {
        pkgs =
          let
            isUpPkgs = !(builtins.isNull nixpkgs);
            mypkgs = if isUpPkgs then nixpkgs else stableNixpkgs;
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
