{ lib, fetchurl, stdenv, p7zip }:

let version = "0.0.32";
in stdenv.mkDerivation {
  name = "codicons-${version}";
  src = fetchurl {
    url =
      "https://github.com/microsoft/vscode-codicons/raw/${version}/dist/codicon.ttf";
    sha256 = "1rqr99gamciwdcsfp456kfr4rdnm886axq7jyn976yjlbzqwpk3i";
  };
  dontInstall = true;
  unpackPhase = ''
    _src=$(stripHash "$src")
    cp -rv $src $_src
    install -D -m644 -t $out/share/fonts/truetype $_src
  '';
  meta = with lib; {
    description = "The icon font for Visual Studio Code ";
    homepage = "https://github.com/microsoft/vscode-codicons";
    license = licenses.cc-by-40;
    # maintainers = [ maintainers.marsam ];
    platforms = platforms.all;
  };
}
