{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "iina+";
  version = "0.7.16";
  pathdir = "IINA+";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/xjbeta/iina-plus/releases/download/${version}/IINA+.${version}.dmg";
    sha256 = "0803b3b7k7cbnn59j4yrhfjkcv48kga9la0whhv70ay8bg7sqxc9";
  };
  appMeta = {
    description = "Extra danmaku support for iina (iina 弹幕支持)";
    homepage = "https://github.com/xjbeta/iina-plus";
  };
}
