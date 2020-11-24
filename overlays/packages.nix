final: prev: {
  my = {
    fantasquesansmono = prev.callPackage ../packages/fantasquesansmono.nix {};
    fira-sans = prev.callPackage ../packages/fira-sans.nix {};
    mononoki = prev.callPackage ../packages/mononoki.nix {};
  };
}
