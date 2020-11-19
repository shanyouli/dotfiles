{ stdenv, fetchurl, lib, unzip, enableWindowsFonts ? false }:

stdenv.mkDerivation rec {
  pname = "Mononoki";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${pname}.zip";
    sha256 = "074avnvfl260pcrli4h5bc55yqr4mgd54paf80qcnh101qsz325w";
  };
  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";
  buildPhase = ''
    echo "Install NerdFonts-${pname}.${version}"
  '';
  installPhase = ''
    find -name \*.ttf -exec mkdir -p $out/share/fonts/truetype \; -exec mv {} $out/share/fonts/truetype \;
    ${lib.optionalString (! enableWindowsFonts) ''
      rm -rfv $out/share/fonts/truetype/*Windows\ Compatible.*
    ''}
  '';
  meta = with stdenv.lib; {
    description = "Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts";
    longDescription = ''
      Nerd Fonts is a project that attempts to patch as many developer targeted
      and/or used fonts as possible. The patch is to specifically add a high
      number of additional glyphs from popular 'iconic fonts' such as Font
      Awesome, Devicons, Octicons, and others.
    '';
    homepage = "https://nerdfonts.com/";
    license = licenses.mit;
    maintainers = with maintainers; [ doronbehar ];
    hydraPlatforms = []; # 'Output limit exceeded' on Hydra
  };
}
