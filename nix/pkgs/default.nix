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
      _module.args.pkgs = import inputs.nixpkgs-stable {
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
