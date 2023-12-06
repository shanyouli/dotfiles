{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "xbydriver";
  version = "3.12.2";
  pathdir = "小白羊云盘 ${version}-arm64";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/gaozhangmin/aliyunpan/releases/download/v${version}/XBYDriver-${version}-mac-arm64.dmg";
    sha256 = "sha256-0Wgrei3QyrdlfLdpCnp53XCp2IKYm65ldeOKiU/P3w0=";
  };
  appMeta = {
    description = "小白羊网盘 - Powered by 阿里云盘。";
    homepage = "https://github.com/gaozhangmin/aliyunpan";
  };
}
