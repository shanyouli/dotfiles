{ fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "icons-in-terminal";
  version = "20170725";
  src = fetchurl {
    url = "https://github.com/sebastiencs/icons-in-terminal/raw/d79b930467f1e245494056b0c6bb6feb135fdf68/build/icons-in-terminal.ttf";
    sha256 = "sha256-Bdg/XQgDjmEo/dqt4nbjlHxKP/gef0y8YxM+tcxbIOg=";
  };
  buildCommand = ''
    dst=$out/share/fonts/truetype
    mkdir -p "$dst"
    install -v -m644 "$src" "$dst"
  '';
}
