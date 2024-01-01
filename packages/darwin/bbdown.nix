{
  lib,
  fetchurl,
  stdenv,
  unzip,
}:
stdenv.mkDerivation rec {
  pname = "BBDown";
  version = "1.6.1";
  src = fetchurl {
    url = "https://github.com/nilaoda/BBDown/releases/download/1.6.1/BBDown_1.6.1_20230818_osx-arm64.zip";
    sha256 = "sha256-0MmnYDgzpGbrFToXJ5dIxDqcp30QqE32jA1mu6HtbYs=";
  };
  sourceRoot = ".";
  nativeBuildInputs = [unzip];
  # dontInstall = true;
  installPhase = ''
    install -D -m755 -t $out/bin bbdown
  '';

  meta = with lib; {
    description = ''
      一款命令行式哔哩哔哩下载器. Bilibili Downloader.
    '';
    homepage = "https://github.com/nilaoda/BBDown";
    platforms = platforms.darwin;
    maintainers = with maintainers; [shanyouli];
    license = licenses.mit;
  };
}
