{
  mkDarwinApp,
  source,
  sources,
  p7zip,
  makeWrapper,
  ...
}: let
  realSrc = sources.calibrepath.src;
in
  mkDarwinApp rec {
    inherit (source) pname version src;
    nativeBuildInputs = [p7zip makeWrapper];
    postInstall = ''
      mkdir -p $out/tmp
      7z x ${realSrc} -o$out/tmp
      mv -vf $out/tmp/python-lib.bypy.frozen $out/Applications/calibre.app/Contents/Frameworks/plugins
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
