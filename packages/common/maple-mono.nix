{
  lib,
  fetchurl,
  stdenv,
  p7zip,
}: let
  version = "6.3";
in
  stdenv.mkDerivation {
    name = "Maple-mono-${version}";
    src = fetchurl {
      url = "https://github.com/subframe7536/Maple-font/releases/download/v${version}/MapleMono.zip";
      sha256 = "1in5vhjncrp63zzgnrki0jkpzbc9ljvxmx8rzgymq66hzz00x7h2";
    };
    nativeBuildInputs = [p7zip];
    dontInstall = true;
    unpackPhase = ''
      mkdir -p $out/tmp
      7z x $src -o$out/tmp
      pushd $out/tmp
      for i in ttf\\*.ttf ; do
        mv -vf $i ''${i#ttf\\}
      done
      find -name \*.ttf -exec mkdir -p $out/share/fonts/truetype \; -exec mv {} $out/share/fonts/truetype \;
      popd
      rm -rf $out/tmp
    '';
    # installPhase = ''
    # '';

    meta = with lib; {
      description = "Open source monospace/Nerd Font ";
      homepage = "https://github.com/subframe7536/Maple-font";
      license = licenses.ofl;
      # maintainers = [ maintainers.marsam ];
      platforms = platforms.all;
    };
  }
