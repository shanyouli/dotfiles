{
  lib,
  stdenv,
  p7zip,
  source,
}:
stdenv.mkDerivation {
  inherit (source) src pname version;
  # name = "Maple-SC-NF-${version}";
  # src = fetchurl {
  #   url = "https://github.com/subframe7536/Maple-font/releases/download/v${version}/MapleMono-SC-NF.zip";
  #   sha256 = "1h0xf2scaidif89x9blpyfjpkjqfgf10vc0wnln4r315cf91vanv";
  # };
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
