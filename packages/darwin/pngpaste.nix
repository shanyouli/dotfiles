{
  stdenv,
  darwin,
  lib,
  source,
}:
stdenv.mkDerivation rec {
  inherit (source) pname version src;
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
