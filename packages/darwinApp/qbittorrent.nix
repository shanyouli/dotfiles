{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "qbittorrent";
  version = "4.6.1.10";
  src = fetchurl {
    url = "https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${version}/qBittorrent-Enhanced-Edition-release-${version}-macOS-universal.dmg";
    sha256 = "sha256-MoB5EzBhX7sJRZnLgbAsgVHHfwSZ70hSjO5FpAi5LEg=";
  };
  appMeta = {
    description = "[Unofficial] qBittorrent Enhanced, based on qBittorrent";
    homepage = "https://github.com/c0re100/qBittorrent-Enhanced-Edition";
  };
}
