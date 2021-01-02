final: prev: let
  inherit (prev.lib) recurseIntoAttrs;
  python3Override = {
    packageOverrides = self: super: {
    } // prev.callPackage ../packages/python3-modes.nix { };
  };
in rec {
  python3 = prev.python3.override python3Override;
  my = {
    feeluown-full = prev.callPackage ../packages/feeluown-full.nix {};
    fira-sans = prev.callPackage ../packages/fira-sans.nix { };
    xkeysnail = prev.python3Packages.callPackage ../packages/xkeysnail.nix { };
    zyplayer = prev.callPackage ../packages/zy-player.nix {};
    tmuxifier = prev.callPackage ../packages/tmuxifier.nix {};
    wqy-microhei = prev.callPackage ../packages/wqy-microhei-rk.nix {};
    icons-in-terminal = prev.callPackage ../packages/icons-in-terminal.nix {};
  };
  firefox-addons = recurseIntoAttrs (prev.callPackage ../packages/firefox-addons { });
  nerd-fonts = recurseIntoAttrs (prev.callPackage ../packages/nerd-fonts { });
  rime-data = recurseIntoAttrs (prev.callPackage ../packages/rime-data.nix {});
}
