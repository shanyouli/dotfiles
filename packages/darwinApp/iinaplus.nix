{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "iina+";
  version = "0.7.15";
  pathdir = "IINA+";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/xjbeta/iina-plus/releases/download/${version}/IINA+.${version}.dmg";
    sha256 = "0xa3jmy0vlq1x077na8qlcnsxsvwkyv3hhwqx4x8p0jx879gbvdg";
  };
  appMeta = {
    description = "Extra danmaku support for iina (iina 弹幕支持)";
    homepage = "https://github.com/xjbeta/iina-plus";
  };
}
