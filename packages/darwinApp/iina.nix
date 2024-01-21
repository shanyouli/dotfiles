{
  fetchurl,
  mkDarwinApp,
  makeWrapper,
  ...
}:
mkDarwinApp rec {
  appName = "IINA";
  version = "1.3.4";
  src = fetchurl {
    url = "https://github.com/iina/iina/releases/download/v${version}/IINA.v${version}.dmg";
    sha256 = "136p518bdnjamlrsbbvs3hrhak07c0h1p8srpwkmpzd2sid0zrbx";
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
