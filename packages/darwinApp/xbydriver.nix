{
  mkDarwinApp,
  source,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  meta = {
    description = "小白羊网盘 - Powered by 阿里云盘。";
    homepage = "https://github.com/gaozhangmin/aliyunpan";
  };
}
