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
  appname = "LyricsX";
  meta = {
    description = "🎶 Ultimate lyrics app for macOS. ";
    homepage = "https://github.com/ddddxxx/LyricsX";
  };
}
