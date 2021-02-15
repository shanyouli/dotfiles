{ stdenv, fetchurl,}:
let
  baseUrl = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download";
in stdenv.mkDerivation rec {
  pname = "xray-asset";
  version = "202102142209";
  srcs = [
    (fetchurl {
      url = "${baseUrl}/${version}/geoip.dat";
      sha256 = "sha256-rM5ivLRenLgywC2l4te11hX8e19HccY1akBuFEn1Zz8=";
    })
    (fetchurl {
      url = "${baseUrl}/${version}/geosite.dat";
      sha256 = "sha256-VOWCFhpdEzdeENs/WozV+c6ZUBK4NfaQRvkUlAfdzxU=";
    })
  ];
  unpackPhase = ''
    for _src in $srcs; do
      cp "$_src" $(stripHash "$_src")
    done
  '';
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/${pname}
    for file in *.dat ; do
      cp -r "$file" $out/share/${pname}
    done
  '';
}
