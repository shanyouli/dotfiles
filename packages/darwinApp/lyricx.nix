{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "LyricsX";
  version = "1.6.4";
  useZip = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/go-musicfox/LyricsX/releases/download/v${version}/LyricsX_${version}.zip";
    sha256 = "07alwvi1dy67gwcmr6w0c8n5b1npicwj3mf374jv8s7n567g8j64";
  };
  appMeta = {
    description = "🎶 Ultimate lyrics app for macOS. ";
    homepage = "https://github.com/ddddxxx/LyricsX";
  };
}
