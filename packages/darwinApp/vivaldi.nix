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
  appname = "Vivaldi";
  meta = {
    description = "Vivaldi Browser";
    homepage = "https://vivaldi.com/";
  };
}
