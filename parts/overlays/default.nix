{
  inputs,
  self,
  ...
}: {
  flake.overlays = rec {
    base = inputs.nurpkgs.overlays.default;
    python = import ./python.nix;

    default = final: prev: {
      unstable = import inputs.nixpkgs rec {
        inherit (prev) system;
        config.allowUnfree = true;
        overlays = [
          self.overlays.base
          (ffinal: pprev: {
            my = {
              nix-index = inputs.nurpkgs.packages.${prev.system}.nix-index;
              emacs = inputs.nurpkgs.packages.${prev.system}.emacs;
              emacs-git = inputs.nurpkgs.packages.${prev.system}.emacsGit;
            };
          })
        ];
      };
    };
  };
  flake.overlay = self.overlays.default;
}
