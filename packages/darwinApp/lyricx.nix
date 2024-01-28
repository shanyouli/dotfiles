{
  mkDarwinApp,
  source,
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  appname = "LyricsX";
  meta = {
    description = "🎶 Ultimate lyrics app for macOS. ";
    homepage = "https://github.com/ddddxxx/LyricsX";
  };
}
