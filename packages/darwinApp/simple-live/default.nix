{
  mkDarwinApp,
  fetchurl,
  ...
}: let
  source = (builtins.fromJSON (builtins.readFile ./source.json))."simpleLive";
  version = source.version;
in
  mkDarwinApp rec {
    inherit version;
    src = fetchurl {
      inherit (source) url sha256;
    };
    pname = "simple-live";
    appname = "SimpleLive";
    meta = {
      description = "Simple Live 简简单单的看直播 ";
      homepage = "https://github.com/xiaoyaocz/dart_simple_live";
    };
  }
