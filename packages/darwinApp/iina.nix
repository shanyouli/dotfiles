{
  mkDarwinApp,
  makeWrapper,
  source,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  appname = "IINA";
  meta = {
    description = "IINA mplayer";
    homepage = "http://iina.io/";
  };
  nativeBuildInputs = [makeWrapper];
  postInstall = ''
    makeWrapper $out/Applications/IINA.app/Contents/MacOS/iina-cli $out/bin/iina
  '';
}
