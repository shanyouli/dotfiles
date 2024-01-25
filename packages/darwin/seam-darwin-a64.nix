{
  lib,
  fetchurl,
  stdenv,
}:
stdenv.mkDerivation rec {
  name = "seam";
  version = "0.1.23";
  src = fetchurl {
    url = "https://github.com/borber/seam/releases/download/v${version}/seam-v${version}.aarch64-apple-darwin.tar.xz";
    sha256 = "1nx9mgj51f50nv4zagrbfbr1gs8by9n0hk4pan3zjbwdykb28321";
  };
  sourceRoot = ".";
  # dontInstall = true;
  installPhase = ''
    install -D -m755 -t $out/bin seam
  '';

  meta = with lib; {
    description = ''
      获取斗鱼，虎牙，哔哩哔哩，抖音，网易CC，快手，花椒，映客 等直播平台的真实流媒体地址（直播源），
      可在mpv，PotPlayer、flv.js等播放器中播放。将针对性推出不同侧重点的 cli， gui， server 程序.
    '';
    homepage = "https://github.com/Borber/seam";
    platforms = ["aarch64-darwin"];
    maintainers = with maintainers; [shanyouli];
    license = licenses.gpl3;
  };
}
