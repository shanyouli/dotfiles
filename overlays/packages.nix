final: prev: with prev; {
  my = {
    fira-sans = callPackage ../packages/fira-sans.nix { };
    xkeysnail = python3Packages.callPackage ../packages/xkeysnail.nix { };
    zyplayer = callPackage ../packages/zy-player.nix {};
    tmuxifier = callPackage ../packages/tmuxifier.nix {};
    wqy-microhei = callPackage ../packages/wqy-microhei-rk.nix {};
    icons-in-terminal = callPackage ../packages/icons-in-terminal.nix {};
  };
  firefox-addons = recurseIntoAttrs (callPackage ../packages/firefox-addons { });
  nerd-fonts = recurseIntoAttrs (callPackage ../packages/nerd-fonts { });
  rime-data = recurseIntoAttrs (callPackage ../packages/rime-data.nix {});
}
