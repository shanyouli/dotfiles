{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "qbittorrent";
  version = "4.5.5.10";
  src = fetchurl {
    url = "https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${version}/qBittorrent-Enhanced-Edition-release-${version}-macOS-universal.dmg";
    sha256 = "0gy3askm429zfmgy2xhy1ynpdnmslnbw013srpf8l3085rhl2l6i";
  };
  appMeta = {
    description = "Keyboard-driven, vim-like browser based on PyQt5";
    homepage = "https://www.qutebrowser.org/";
  };
}
