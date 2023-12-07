{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "zyplayer";
  version = "3.3.0";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/Hiram-Wong/ZyPlayer/releases/download/v${version}/zyplayer-mac-${version}-arm64.dmg";
    sha256 = "sha256-ekl/i1wb29a6QmV7n9aTjpQqCegPwgMGfEoMwC7OU84=";
  };
  pathdir = "zyplayer ${version}-arm64";
  appMeta = {
    description = "跨平台视频资源播放器, 简洁免费无广告.";
    # homepage = "http://zyplayer.fun/";
    homepage = "https://github.com/Hiram-Wong/ZyPlayer";
  };
}
