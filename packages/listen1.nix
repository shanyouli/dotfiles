{ appimageTools, fetchurl, lib, gsettings-desktop-schemas, gtk3 }:
# A great Net Music Player
# code from: @https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/office/timeular/default.nix
let
  inherit (appimageTools) extractType2 wrapType2;
  pname = "listen1";
  version = "2.17.9";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/listen1/listen1_desktop/releases/download/v${version}/${pname}_${version}_linux_x86_64.AppImage";
    sha256 = "1jsqjm2031pzc5z3kzvlahhfwxrs6kaf43iwr6ahnib8cbd9lsj5";
  };
  appimageContents = extractType2 { inherit name src; };
in wrapType2 rec {
  inherit name src;
  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
    export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
    export FONTCONFIG_FILE=/etc/fonts/fonts.conf
  '';

  multiPkgs = null; # no 32bit needed
  extraPkgs = p:(appimageTools.defaultFhsEnvArgs.multiPkgs p);
  extraInstallCommands = let
    desktop = "$out/share/applications/${pname}.desktop";
  in ''
    mv $out/bin/{${name},${pname}}
    install -m 444 -D ${appimageContents}/listen1.desktop ${desktop}
    substituteInPlace ${desktop} --replace 'Exec=AppRun' 'Exec=${pname}'
    substituteInPlace ${desktop} --replace 'Icon=${pname}' 'Icon=${appimageContents}/${pname}.png'
  '';

  meta = with lib; {
    description = "One for all free music in China";
    homepage = "http://listen1.github.io/listen1/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ syl ];
  };
}
