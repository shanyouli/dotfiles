{
  stdenv,
  fetchurl,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "deeplx";
  version = "0.8.3";
  src =
    if stdenv.isDarwin
    then
      fetchurl {
        url = "https://github.com/OwO-Network/DeepLX/releases/download/v${version}/deeplx_darwin_arm64";
        sha256 = "sha256-1c6WR2Gpkfs5VZY2joNd/+YZWTzZRSCC+7829wVCZPQ=";
      }
    else {
      url = "https://github.com/OwO-Network/DeepLX/releases/download/v${version}/deeplx_linux_amd64";
      sha256 = "1ndrnlcmhw17bqjkcf9v455k7i7ny47lj9h420kys80slcwyjxyp";
    };
  unpackPhase = ''
    cp $src deeplx
  '';
  dontBuild = true;
  installPhase = ''
    install -D -m755 -t $out/bin deeplx
  '';

  broken = ! ((stdenv.isDarwin && stdenv.isAarch64) || (stdenv.isLinux && stdenv.isx86_64));
  meta = with lib; {
    description = ''
      DeepL Free API (No TOKEN required)
    '';
    homepage = "https://github.com/OwO-Network/DeepLX";
    platforms = with platforms; [darwin linux];
    maintainers = with maintainers; [shanyouli];
    license = licenses.gpl3;
  };
}
