{
  mkDarwinApp,
  source,
  lib,
  ...
}:
mkDarwinApp rec {
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  inherit (source) pname src;
  meta = {
    description = "小白羊网盘 - Powered by 阿里云盘。";
    homepage = "https://github.com/gaozhangmin/aliyunpan";
  };
}
