{
  lib,
  fetchurl,
  stdenv,
}:
stdenv.mkDerivation rec {
  name = "alist";
  version = "3.29.1";
  src = fetchurl {
    url = "https://github.com/alist-org/alist/releases/download/v${version}/alist-darwin-arm64.tar.gz";
    sha256 = "sha256-t01TeEOJAw4DqkPgkTMX4bw0/E2kYR+Hc46wlrsY9Is=";
  };
  sourceRoot = ".";
  # dontInstall = true;
  installPhase = ''
    install -D -m755 -t $out/bin alist
  '';

  meta = with lib; {
    description = ''
      🗂️A file list program that supports multiple storage, powered by Gin and Solidjs.
    '';
    homepage = "https://github.com/alist-org/alist";
    platforms = platforms.darwin;
    maintainers = with maintainers; [shanyouli];
    license = licenses.gpl3;
  };
}
