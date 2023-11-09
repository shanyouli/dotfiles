{ lib, fetchurl, stdenv, unzip }:
stdenv.mkDerivation rec {
  pname = "mosdns";
  version = "5.1.2";
  src = fetchurl {
    url = "https://github.com/IrineSistiana/mosdns/releases/download/v${version}/mosdns-darwin-arm64.zip";
    sha256 = "sha256-UUdbK8ohfoENETK0ORRF3axy5v2wcPGxgPHKGmKq5dw=";
  };
  sourceRoot = ".";
  nativeBuildInputs = [ unzip ];
  # dontInstall = true;
  installPhase = ''
    install -D -m755 -t $out/bin mosdns
  '';

  meta = with lib; {
    description = ''
      一个 DNS 转发器
    '';
    homepage = "https://github.com/IrineSistiana/mosdns";
    platforms = platforms.darwin;
    maintainers = with maintainers; [ shanyouli ];
    license = licenses.gpl3;
  };
}
