{
  mkDarwinApp,
  makeWrapper,
  sources,
  lib,
  stdenv,
  ...
}: let
  pname = "Chromium";
  source =
    if stdenv.isAarch64
    then sources."chromium.arm64"
    else sources."chromium.x64";
in
  mkDarwinApp rec {
    inherit pname;
    inherit (source) src;
    version =
      if (builtins.hasAttr "date" source)
      then source.date
      else lib.removePrefix "v" source.version;
    appname = "Chromium";
    meta = {
      description = "Open source version of Google-chrome";
      homepage = "https://github.com/ungoogled-software/ungoogled-chromium";
    };
    nativeBuildInputs = [makeWrapper];
    postInstall = ''
      makeWrapper "$out/Applications/${appname}.app/Contents/MacOS/Chromium" \
        "$out/Applications/${appname}.app/Contents/MacOS/Google Chrome"
    '';
  }
