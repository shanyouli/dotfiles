{
  mkDarwinApp,
  source,
  lib,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  appname = "LocalSend";
  meta = {
    description = "Share files to nearby devices. Free, open source, cross-platform";
    homepage = "https://localsend.org/#/";
  };
}
