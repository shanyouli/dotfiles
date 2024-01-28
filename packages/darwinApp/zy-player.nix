{
  mkDarwinApp,
  source,
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  meta = {
    description = "跨平台视频资源播放器, 简洁免费无广告.";
    # homepage = "http://zyplayer.fun/";
    homepage = "https://github.com/Hiram-Wong/ZyPlayer";
  };
}
