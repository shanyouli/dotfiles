{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "zyplayer";
  version = "3.3.1";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/Hiram-Wong/ZyPlayer/releases/download/v${version}/zyplayer-mac-${version}-arm64.dmg";
    sha256 = "1s7idrl8j616sy2187gfzalh193a20zws0c3hbwyw9kar5lyd3gz";
  };
  pathdir = "zyplayer ${version}-arm64";
  appMeta = {
    description = "跨平台视频资源播放器, 简洁免费无广告.";
    # homepage = "http://zyplayer.fun/";
    homepage = "https://github.com/Hiram-Wong/ZyPlayer";
  };
}
