{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "xbydriver";
  version = "3.12.1";
  pathdir = "小白羊云盘 3.12.1-arm64";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/gaozhangmin/aliyunpan/releases/download/v${version}/XBYDriver-${version}-mac-arm64.dmg";
    sha256 = "10w1nnzgf8bw1vnkcgi99x4ja99g8gsa2qi9gi6lv8bymvngvgv8";
  };
  appMeta = {
    description = "小白羊网盘 - Powered by 阿里云盘。";
    homepage = "https://github.com/gaozhangmin/aliyunpan";
  };
}
