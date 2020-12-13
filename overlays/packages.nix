final: prev: with prev; {
  my = {
    fira-sans = callPackage ../packages/fira-sans.nix { };
    xkeysnail = python3Packages.callPackage ../packages/xkeysnail.nix { };
    zyplayer = callPackage ../packages/zy-player.nix {};
    tmuxifier = callPackage ../packages/tmuxifier.nix {};
  };
  firefox-addons = recurseIntoAttrs (callPackage ../packages/firefox-addons { });
  nerd-fonts = recurseIntoAttrs (callPackage ../packages/nerd-fonts { });
}
