{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "iina+";
  version = "0.7.12";
  pathdir = "IINA+";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/xjbeta/iina-plus/releases/download/${version}/IINA+.${version}.dmg";
    sha256 = "1vlmh48ldb17bfxil9lbh5nn0zcavr8mdd7242krsk6ac66l7281";
  };
  appMeta = {
    description = "Extra danmaku support for iina (iina 弹幕支持)";
    homepage = "https://github.com/xjbeta/iina-plus";
  };
}
