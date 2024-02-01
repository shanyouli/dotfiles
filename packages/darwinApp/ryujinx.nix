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
  appname = "Ryujinx";
  meta = {
    description = "A simple, experimental Nintendo Switch emulator";
    homepage = "https://ryujinx.org";
  };
}
