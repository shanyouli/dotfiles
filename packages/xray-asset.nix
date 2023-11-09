{ stdenv, fetchurl,}:
let
  baseUrl = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download";
in stdenv.mkDerivation rec {
  pname = "xray-asset";
  version = "202303042209";
  srcs = [
    (fetchurl {
      url = "${baseUrl}/${version}/geoip.dat";
      sha256 = "sha256-NX43TxbjNsdJUWVmup8L3u8k7MwBN2lpn+Qc+tFJcR8=";
    })
    (fetchurl {
      url = "${baseUrl}/${version}/geosite.dat";
      sha256 = "sha256-PFev5DgBR5I7Xc8MEXZe+oLvDfw85/abWmf6t9hIAmQ=";
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
