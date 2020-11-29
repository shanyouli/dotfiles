final: prev: with prev; {
  my = {
    fantasquesansmono = callPackage ../packages/fantasquesansmono.nix { };
    fira-sans = callPackage ../packages/fira-sans.nix { };
    mononoki = callPackage ../packages/mononoki.nix { };
    xkeysnail = python3Packages.callPackage ../packages/xkeysnail.nix { };
    firefox-addons =
      prev.recurseIntoAttrs (callPackage ./packages/firefox-addons { });
  };
}
