{
  lib,
  stdenv,
  p7zip,
  source,
}:
stdenv.mkDerivation {
  inherit (source) src pname;

  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
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

  meta = with lib; {
    description = "Open source monospace/Nerd Font ";
    homepage = "https://github.com/subframe7536/Maple-font";
    license = licenses.ofl;
    # maintainers = [ maintainers.marsam ];
    platforms = platforms.all;
  };
}
