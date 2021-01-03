final: prev: let
  inherit (prev.lib) recurseIntoAttrs;
  python3Override = {
    packageOverrides = self: super: {
    } // prev.callPackage ./python3-modes.nix { };
  };
  emacsOverride = self: super: {
    _0xc = null;
    _2048 = null;
  } // prev.callPackage ./emacs-modes.nix { };
in rec {
  python3 = prev.python3.override python3Override;

  emacsPackages = recurseIntoAttrs (prev.emacsPackages.overrideScope' emacsOverride);
  emacsPackagesFor = emacs: recurseIntoAttrs ((prev.emacsPackagesFor emacs).overrideScope' emacsOverride);

  my = {
    feeluown-full = prev.callPackage ./feeluown-full.nix {};
    fira-sans = prev.callPackage ./fira-sans.nix { };
    xkeysnail = prev.python3Packages.callPackage ./xkeysnail.nix { };
    zyplayer = prev.callPackage ./zy-player.nix {};
    tmuxifier = prev.callPackage ./tmuxifier.nix {};
    wqy-microhei = prev.callPackage ./wqy-microhei-rk.nix {};
    icons-in-terminal = prev.callPackage ./icons-in-terminal.nix {};
  };
  firefox-addons = recurseIntoAttrs (prev.callPackage ./firefox-addons { });
  nerd-fonts = recurseIntoAttrs (prev.callPackage ./nerd-fonts { });
  rime-data = recurseIntoAttrs (prev.callPackage ./rime-data.nix {});
}
