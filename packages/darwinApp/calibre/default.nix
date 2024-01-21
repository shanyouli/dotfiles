# {pkgs ? import <nixpkgs> {}}:
# with pkgs;
# with pkgs.lib;
{
  fetchurl,
  stdenv,
  undmg,
  p7zip,
  makeWrapper,
  ...
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  version = source."calibre".version;
  baseSrc = fetchurl {
    inherit (source."calibre") url sha256;
  };
  frozenSrc = fetchurl {
    inherit (source."calibrepath") url sha256;
  };
in
  stdenv.mkDerivation rec {
    inherit version;
    pname = "calibre";
    buildInputs = [undmg p7zip makeWrapper];
    sourceRoot = ".";
    srcs = [baseSrc frozenSrc];
    phases = ["installPhase"];
    installPhase = ''
      # undmg ${baseSrc}
      /usr/bin/hdiutil attach ${baseSrc}
      mkdir -p $out/Applications
      cp -rv /Volumes/calibre-${version}/*.app $out/Applications
      mkdir -p $out/tmp
      7z x ${frozenSrc} -o$out/tmp
      mv $out/tmp/python-lib.bypy.frozen $out/Applications/calibre.app/Contents/Frameworks/plugins
      rm -rf $out/tmp
      for i in "calibre" "calibre-complete" "calibre-customize" "calibre-debug" "calibre-parallel" \
          "calibre-server" "calibre-smtp" "calibredb" "ebook-convert" "ebook-device" "ebook-edit" \
          "ebook-meta" "ebook-polish" "ebook-viewer" "fetch-ebook-metadata" "lrf2lrs" "lrfviewer" \
          "lrs2lrf" "markdown-calibre" "web2disk"; do

        makeWrapper $out/Applications/calibre.app/Contents/MacOS/$i $out/bin/$i
      done
    '';

    meta = {
      description = "ebook management";
      homepage = "https://calibre-ebook.com/";
    };
  }
