{
  mkDarwinApp,
  source,
  lib,
}:
mkDarwinApp rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  meta = {
    description = "跨平台视频资源播放器, 简洁免费无广告.";
    # homepage = "http://zyplayer.fun/";
    homepage = "https://github.com/Hiram-Wong/ZyPlayer";
  };
}
