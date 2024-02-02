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
  appname = "spotube";
  meta = {
    description = "Open source Spotify client";
    homepage = "https://github.com/KRTirtho/spotube";
  };
}
