{
  mkDarwinApp,
  source,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  appname = "iina+";
  meta = {
    description = "Extra danmaku support for iina (iina 弹幕支持)";
    homepage = "https://github.com/xjbeta/iina-plus";
  };
}
