{
  mkDarwinApp,
  source,
  lib,
}:
mkDarwinApp rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  appname = "RyuSAK";
  meta = {
    description = "Color finder for switch emulator";
    homepage = "https://github.com/FennyFatal/RyuSAK";
  };
}
