{
  mkDarwinApp,
  makeWrapper,
  sources,
  lib,
  stdenv,
  ...
}: let
  pname = "google-chrome";
  source =
    if stdenv.isAarch64
    then sources."chrome.arm64"
    else sources."chrome.x64";
in
  mkDarwinApp rec {
    inherit pname;
    inherit (source) src;
    version =
      if (builtins.hasAttr "date" source)
      then source.date
      else lib.removePrefix "v" source.version;
    appname = "Google Chrome";
    meta = {
      description = "Google Chrome stable";
      homepage = "https://www.google.com/chrome/";
    };
    nativeBuildInputs = [makeWrapper];
    postInstall = ''
      makeWrapper "$out/Applications/${appname}.app/Contents/MacOS/Google Chrome for Testing" \
        "$out/Applications/${appname}.app/Contents/MacOS/${appname}"
    '';
  }
