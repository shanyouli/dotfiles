{ stdenv, fetchFromGitHub, }:
# see https://git.savannah.gnu.org/cgit/guix.git/tree/gnu/packages/tmux.scm#n100
# see https://github.com/jimeh/tmuxifier
stdenv.mkDerivation rec {
  pname = "tmuxifier";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "jimeh";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-7TvJnvtZEo5h45PcSy3tJN09UblswV0mQbTaKjgLyqw=";
  };
  # dontBuild = true;
  buildPhase = ''
    sed -i "/set -e/a #\nexport TMUXIFIER=$out/share/tmuxifier \
      \nexport TMUXFIER_LAYOUT_PATH=$\{TMUXFIER_LAYOUT_PATH:-$\HOME/.tmuxifier}" \
      bin/tmuxifier
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/${pname}
    install -m0755 bin/tmuxifier $out/bin

    for i in "completion" "lib" "libexec" "templates" "init.*"; do
      cp -r $i $out/share/${pname}
    done

    runHook postInstall
  '';
  # postInstall = ''
  # '';
  meta = with stdenv.lib; {
    description = "Tmux Window management tool.";
    homepage = "https://github.com/jimeh/tmuxifier";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ maintainers.syl ];
  };
}
