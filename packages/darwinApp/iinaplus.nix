{
  mkDarwinApp,
  source,
  lib,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  appname = "iina+";
  meta = {
    description = "Extra danmaku support for iina (iina 弹幕支持)";
    homepage = "https://github.com/xjbeta/iina-plus";
  };
}
