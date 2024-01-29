{
  mkDarwinApp,
  makeWrapper,
  source,
  lib,
}:
mkDarwinApp rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  appname = "uPic";
  nativeBuildInputs = [makeWrapper];
  postInstall = ''
    makeWrapper $out/Applications/uPic.app/Contents/MacOS/uPic $out/bin/upic
  '';
  meta = {
    description = "upic 图床管理";
    homepage = "https://github.com/gee1k/uPic";
  };
}
