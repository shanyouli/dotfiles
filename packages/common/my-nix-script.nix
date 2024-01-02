{
  lib,
  stdenv,
}:
stdenv.mkDerivation rec {
  name = "nix-scripts";
  src = ../../bin;
  buildInputs = [];
  installPhase = ''
    mkdir -p $out/bin
    find . -maxdepth 1 -perm -a+x -not -name '*.*' \
      -exec cp -pL {} $out/bin \;
  '';

  meta = with lib; {
    description = "my scripts bin";
    homepage = https://github.com/shanyouli/system;
    license = licenses.mit;
    maintainers = with maintainers; [shanyouli];
    platforms = platforms.all;
  };
}
