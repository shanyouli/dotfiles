{
  mkDarwinApp,
  fetchurl,
}: let
  pname = "rpcs3";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  version = source."${pname}".version;
  src = fetchurl {
    inherit (source."${pname}") url sha256;
  };
in
  mkDarwinApp rec {
    inherit pname version src;
    appname = "RPCS3";
    meta = {
      description = "rpcs3";
      homepage = "https://github.com/RPCS3";
    };
  }
