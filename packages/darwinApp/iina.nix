{
  fetchurl,
  mkDarwinApp,
  makeWrapper,
  ...
}:
mkDarwinApp rec {
  appName = "IINA";
  version = "1.3.3";
  src = fetchurl {
    url = "https://github.com/iina/iina/releases/download/v${version}/IINA.v${version}.dmg";
    sha256 = "4b3f6c4bed3bb77dbe29c12bf6d5d0959284afb01c7b59a35fd71a3a27088991";
  };
  appMeta = {
    description = "IINA mplayer";
    homepage = "http://iina.io/";
  };
  extBuildInputs = [makeWrapper];
  postInstall = ''
    makeWrapper $out/Applications/IINA.app/Contents/MacOS/iina-cli $out/bin/iina
  '';
}
