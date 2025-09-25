{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.overlays = rec {
    base = inputs.nurpkgs.overlays.default;
    python = import ./python.nix;

    default = _final: prev: rec {
      unstable = import inputs.nixpkgs rec {
        inherit (prev) system;
        config.allowUnfree = true;
        overlays = [
          (lib.composeExtensions self.overlays.base (
            _ffinal: _pprev: {
              inherit (inputs.nurpkgs.packages.${prev.system})
                emacs
                nix-index
                emacs-unstable
                emacs-git
                emacs-igc
                ;
            }
          ))
        ];
      };
    };
  };
  flake.overlay = self.overlays.default;
}
