{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "qbittorrent";
  version = "4.6.0.10";
  src = fetchurl {
    url = "https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${version}/qBittorrent-Enhanced-Edition-release-${version}-macOS-universal.dmg";
    sha256 = "14qmy05v2hbyy2dgf77jcdhfmswrs5rnndfy2avl971mhp5i4qzx";
  };
  appMeta = {
    description = "Keyboard-driven, vim-like browser based on PyQt5";
    homepage = "https://www.qutebrowser.org/";
  };
}
