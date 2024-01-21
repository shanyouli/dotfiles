{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "xbydriver";
  version = "3.12.3";
  pathdir = "小白羊云盘 ${version}-arm64";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/gaozhangmin/aliyunpan/releases/download/v${version}/XBYDriver-${version}-mac-arm64.dmg";
    sha256 = "sha256-SKDkDu9gEgghTUZ7ku7qsa2KMkaMvyNTvtx77CM0VDg=";
  };
  appMeta = {
    description = "小白羊网盘 - Powered by 阿里云盘。";
    homepage = "https://github.com/gaozhangmin/aliyunpan";
  };
}
