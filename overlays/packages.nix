final: prev: with prev; {
  my = {
    fantasquesansmono = callPackage ../packages/fantasquesansmono.nix { };
    fira-sans = callPackage ../packages/fira-sans.nix { };
    mononoki = callPackage ../packages/mononoki.nix { };
    xkeysnail = python3Packages.callPackage ../packages/xkeysnail.nix { };
    zyplayer = callPackage ../packages/zy-player.nix {};
    tmuxifier = callPackage ../packages/tmuxifier.nix {};
  };
  firefox-addons = recurseIntoAttrs (callPackage ../packages/firefox-addons { });
  nerd-fonts = recurseIntoAttrs (callPackage ../packages/nerd-fonts { });
}
