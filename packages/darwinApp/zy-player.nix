{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "zyplayer";
  version = "3.2.4";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/Hiram-Wong/ZyPlayer/releases/download/v${version}/zyplayer-mac-${version}-arm64.dmg";
    sha256 = "1k3yssmqk5288fzcnymrgjnvssl1l5883qylirmp4b0rcg77rr5g";
  };
  pathdir = "zyplayer ${version}-arm64";
  appMeta = {
    description = "跨平台视频资源播放器, 简洁免费无广告.";
    homepage = "http://zyplayer.fun/";
  };
}
