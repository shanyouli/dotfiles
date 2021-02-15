{ lib, python3Packages, makeWrapper, pkgs, stdenv, makeDesktopItem
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
  desktopItem = (makeDesktopItem {
    name = "feeluown";
    desktopName = "FeelUOwn";
    icon = "${ext.feeluown}/${python3Packages.python.sitePackages}/feeluown/feeluown.png";
    exec = "feeluown --log-to-file";
    categories = "AudioVideo;Audio;Player;Qt";
    terminal = "false";
    startupNotify = "true";
  });
  pythonEnv = python3Packages.python.withPackages (p: [
    p.marshmallow
    # ext.feeluown
    ] ++ lib.optional dl ext.fuo_dl
    ++ lib.optional local [ p.fuzzywuzzy p.mutagen ext.ful_local ]
    ++ lib.optional xiami ext.fuo_xiami
    ++ lib.optional kuwo ext.fuo_kuwo
    ++ lib.ifEnable netease [ ext.fuo_netease p.beautifulsoup4 p.pycryptodome ]
    ++ lib.optional qqmusic ext.fuo_qqmusic
    ++ lib.optional webengine p.pyqtwebengine );
in stdenv.mkDerivation rec {
  pname = "feeluown-full";
  inherit (src) version;
  src = ext.feeluown;
  dontBuilt = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pythonEnv ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -rv bin/* $out/bin
    for file in $out/bin/*; do
      wrapProgram $file  \
        --prefix PYTHONPATH : "${pythonEnv}/${python3Packages.python.sitePackages}"
    done
    mkdir -p "$out/share/applications/"
    cp "${desktopItem}"/share/applications/* "$out/share/applications/"
    substituteInPlace $out/share/applications/*.desktop --subst-var out
    runHook postInstall
  '';
}
