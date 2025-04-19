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
                nh
                emacs-stable
                ;
              emacs-git = inputs.nurpkgs.packages.${prev.system}.emacsGit;
            }
          ))
        ];
      };
      # NOTE: 这是一个临时方案，由于最新的 home-manager needs pkgs.formats.xml ;
      inherit (unstable) formats;
    };
  };
  flake.overlay = self.overlays.default;
}
