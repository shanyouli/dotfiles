{ inputs, self, ... }:
{
  flake.overlays = rec {
    base = inputs.nurpkgs.overlays.default;
    python = import ./python.nix;

    default = _final: prev: rec {
      unstable = import inputs.nixpkgs rec {
        inherit (prev.stdenv.hostPlatform) system;
        config.allowUnfree = true;
        overlays = [ ];
      };
    };
  };
  flake.overlay = self.overlays.default;
}
