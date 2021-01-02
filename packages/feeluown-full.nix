{ runCommand, lib, python3Packages, makeWrapper, pkgs
, dl ? true
, local ? true
, xiami ? true
, kuwo ? true
, netease ? true
, qqmusic ? true
, webengine ? false
, ... }:
let
  ext  = pkgs.callPackage ./python3-modes.nix {};
  pythonEnv = python3Packages.python.withPackages (p: [
    p.marshmallow
    ext.feeluown
    ] ++ lib.optional dl ext.fuo_dl
    ++ lib.optional local [ p.fuzzywuzzy p.mutagen ext.ful_local ]
    ++ lib.optional xiami ext.fuo_xiami
    ++ lib.optional kuwo ext.fuo_kuwo
    ++ lib.ifEnable netease [ ext.fuo_netease p.beautifulsoup4 p.pycryptodome ]
    ++ lib.optional qqmusic ext.fuo_qqmusic
    ++ lib.optional webengine p.pyqtwebengine );
in runCommand "feeluown-full" {
    buildInputs =  [ pythonEnv ] ;
    nativeBuildInputs = [ makeWrapper ];
  } ''
  for file in ${python3Packages.feeluown}/bin/*; do
    makeWrapper "$file" "$out/bin/$(basename "$file")" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3Packages.python.sitePackages}"
  done
''
