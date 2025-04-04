{
  inputs,
  self,
  lib,
  ...
}: {
  flake.overlays = rec {
    base = inputs.nurpkgs.overlays.default;
    python = import ./python.nix;

    default = _final: prev: {
      unstable = import inputs.nixpkgs rec {
        inherit (prev) system;
        config.allowUnfree = true;
        overlays = [
          (lib.composeExtensions self.overlays.base (_ffinal: _pprev: {
            inherit (inputs.nurpkgs.packages.${prev.system}) emacs nix-index nh emacs-stable;
            emacs-git = inputs.nurpkgs.packages.${prev.system}.emacsGit;
          }))
        ];
      };
    };
  };
  flake.overlay = self.overlays.default;
}
