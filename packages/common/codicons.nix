{
  lib,
  stdenv,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
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
