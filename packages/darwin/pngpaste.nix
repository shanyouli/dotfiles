{
  stdenv,
  darwin,
  fetchFromGitHub,
  lib,
}:
stdenv.mkDerivation rec {
  version = "0.2.3";
  pname = "pngpaste";
  src = fetchFromGitHub {
    owner = "jcsalterego";
    repo = "pngpaste";
    rev = "${version}";
    hash = "sha256-uvajxSelk1Wfd5is5kmT2fzDShlufBgC0PDCeabEOSE=";
  };
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
