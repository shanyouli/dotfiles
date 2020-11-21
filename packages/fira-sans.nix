{ stdenv, fetchzip }:

fetchzip {
  name = "fira-sans-4.202";
  url = "https://github.com/mozilla/Fira/archive/4.202.zip";
  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile Fira-4.202/otf/FiraSans\*.otf -d $out/share/fonts/opentype
  '';
  sha256 = "sha256-ODR2GkPh5dygsB2a69tP+rqcojbftD04XVsCDvfc15s=";
  meta = with stdenv.lib; {
    homepage = "https://mozilla.github.io/Fira/";
    description = "Monospace font for Firefox OS";
    longDescription = ''
      Fira Mono is a monospace font designed by Erik Spiekermann,
      Ralph du Carrois, Anja Meiners and Botio Nikoltchev of Carrois
      Type Design for Mozilla Firefox OS. Available in Regular,
      Medium, and Bold.
    '';
    license = licenses.ofl;
    maintainers = [ maintainers.rycee ];
    platforms = platforms.all;
  };
}
