{
  inputs,
  self,
  lib,
  ...
}:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs =
        let
          inherit (inputs) darwin-stable nixos-stable;
          inherit (self) my;
          mypkgs = if my.isDarwin system then darwin-stable else nixos-stable;
        in
        import mypkgs {
          inherit system;
          overlays = [
            self.overlay
            (lib.composeExtensions self.overlays.base (
              _ffinal: _pprev: {
                inherit (inputs.nurpkgs.packages.${system})
                  emacs
                  nix-index
                  emacs-unstable
                  emacs-git
                  emacs-igc
                  ;
              }
            ))
          ];
          config.allowUnfree = true;
        };
    };
}
