{
  mkDarwinApp,
  makeWrapper,
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
