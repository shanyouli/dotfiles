{
  mkDarwinApp,
  fetchurl,
  ...
}: let
  pname = "xbydriver";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  version = source."${pname}".version;
  src = fetchurl {inherit (source."${pname}") url sha256;};
in
  mkDarwinApp rec {
    inherit pname version src;
    meta = {
      description = "小白羊网盘 - Powered by 阿里云盘。";
      homepage = "https://github.com/gaozhangmin/aliyunpan";
    };
  }
