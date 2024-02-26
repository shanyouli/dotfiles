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
    description = " 哔哩下载姬(跨平台版)downkyi，哔哩哔哩网站视频下载工具，支持批量下载，支持8K、HDR、杜比视界，提供工具箱（音视频提取、去水印等）";
    # homepage = "http://zyplayer.fun/";
    homepage = "https://github.com/yaobiao131/downkyicore";
  };
}
