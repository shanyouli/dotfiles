{
  stdenv,
  darwin,
  lib,
  source,
}:
stdenv.mkDerivation rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  buildInputs = [darwin.apple_sdk.frameworks.Cocoa];
  installPhase = ''
    mkdir -p $out/bin
    cp pngpaste $out/bin/
  '';
  meta = with lib; {
    description = "Paste PNG into files, much like pbpaste does for text. ";
    homepage = "https://github.com/jcsalterego/pngpaste";
    platforms = platforms.darwin;
    maintainers = with maintainers; [shanyouli];
    license = licenses.gpl3;
  };
}
