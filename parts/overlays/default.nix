{inputs, ...}: {
  flake.overlays = {
    default = final: prev: {
      # expose other channels via overlays
    }
  };
  flake.overlay = self.overlays.default;
}
