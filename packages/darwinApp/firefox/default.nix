# {pkgs ? import <nixpkgs> {}}:
# with pkgs;
# with pkgs.lib; let
{
  fetchurl,
  stdenv,
  undmg,
  p7zip,
  lib,
  isEsr ? true,
  isFx ? true,
  ...
}: let
  basename =
    if isEsr
    then "firefox-esr"
    else "firefox";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  version = source."${basename}".version;
  baseSrc = fetchurl {
    name = "Firefox-${version}.dmg";
    inherit (source."${basename}") url sha256;
  };
  fxSrc = fetchurl {
    name = "fx-folder";
    url = "https://github.com/xiaoxiaoflood/firefox-scripts/raw/36115b1/fx-folder.zip";
    sha256 = "1qpqv73h372igg1wmyfpv3mp32qmjz4krpjlhn11nq7xkz68f210";
  };
in
  stdenv.mkDerivation rec {
    inherit version;
    pname = "firefox";
    buildInputs = [undmg p7zip];
    sourceRoot = ".";
    phases = ["installPhase"];
    installPhase = ''
      undmg ${baseSrc}
      mkdir -p $out/Applications
      cp -r Firefox*.app "$out/Applications/Firefox.app"
      ${lib.optionalString isFx ''
        mkdir -p $out/tmp
        7z x ${fxSrc} -o$out/tmp
        # ls $out/tmp
        cp -r $out/tmp/config.js $out/Applications/Firefox.app/Contents/Resources/config.js
        mkdir -p $out/Applications/Firefox.app/Contents/Resources/defaults/pref
        cp -r $out/tmp/defaults/pref/config-prefs.js $out/Applications/Firefox.app/Contents/Resources/defaults/pref
        rm -rf $out/tmp
      ''}
    '';

    srcs = [baseSrc] ++ lib.optionals isFx [fxSrc];

    meta = {
      description = "Mozilla Firefox, free web browser (binary package)";
      homepage = "http://www.mozilla.com/en-US/firefox/";
    };
  }
