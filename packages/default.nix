final: prev: let
  inherit (prev) callPackage;
  inherit (prev.lib) recurseIntoAttrs;
  python3Override = {
    packageOverrides = self: super: prev.callPackage ./python3-modes.nix { };
  };
  emacsOverride = self: super: callPackage ./emacs-modes.nix { };
in rec {
  python3 = prev.python3.override python3Override;

  emacsPackages = recurseIntoAttrs (prev.emacsPackages.overrideScope' emacsOverride);
  emacsPackagesFor = emacs: recurseIntoAttrs ((prev.emacsPackagesFor emacs).overrideScope' emacsOverride);

  my = {
    feeluown-full = callPackage ./feeluown-full.nix { };
    fira-sans = callPackage ./fira-sans.nix { };
    xkeysnail = prev.python3Packages.callPackage ./xkeysnail.nix { };
    zyplayer = callPackage ./zy-player.nix {};
    listen1 = callPackage ./listen1.nix {};
    tmuxifier = callPackage ./tmuxifier.nix {};
    wqy-microhei = callPackage ./wqy-microhei-rk.nix {};
    icons-in-terminal = callPackage ./icons-in-terminal.nix {};
    wrapFirefox = callPackage ./firefox-wrapper.nix {};
    signwriting = callPackage ./signwriting.nix {};
  };
  zinit = callPackage ./zinit.nix {};
  firefox-addons = recurseIntoAttrs (callPackage ./firefox-addons { });
  nerd-fonts = recurseIntoAttrs (callPackage ./nerd-fonts { });
  rime-data = recurseIntoAttrs (callPackage ./rime-data.nix {});
  libdatrie = callPackage ./libdatrie.nix {};
  libthai = callPackage ./libthai.nix { inherit libdatrie; };
  netease-cloud-music = callPackage ./netease-cloud-music.nix {
    inherit libthai;
  };
  eudic = callPackage ./eudic.nix {  };
  xray-asset = callPackage ./xray-asset.nix {};
  xray = callPackage ./xray.nix { inherit xray-asset; };
  annie = callPackage ./annie.nix {};
}
