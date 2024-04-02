{
  mkDarwinApp,
  sources,
  withEsr ? true,
  withFx ? true,
  p7zip,
  lib,
  fetchurl,
  ...
}: let
  fxSrc = sources.fx-folder.src;
  pname =
    if withEsr
    then "firefox-esr"
    else "firefox";
  source = builtins.fromJSON (builtins.readFile ./sources.json);
  version = source."${pname}".version;
  src = fetchurl {
    inherit (source."${pname}") url sha256;
  };
in
  mkDarwinApp rec {
    inherit pname version src;
    appname = "Firefox";
    nativeBuildInputs = [p7zip];
    postInstall =
      ''
      ''
      + lib.optionalString withFx ''
        mkdir -p $out/tmp
        7z x ${fxSrc} -o$out/tmp
        ls $out/tmp
        cp -ar $out/tmp/config.js $out/Applications/Firefox.app/Contents/Resources/config.js
        mkdir -p $out/Applications/Firefox.app/Contents/Resources/defaults/pref
        cp -ar $out/tmp/defaults/pref/config-prefs.js $out/Applications/Firefox.app/Contents/Resources/defaults/pref
        rm -rf $out/tmp
      '';
    meta = {
      description = "Mozilla Firefox, free web browser (binary package)";
      homepage = "http://www.mozilla.com/en-US/firefox/";
    };
  }
