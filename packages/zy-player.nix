{ appimageTools, fetchurl, lib, gsettings-desktop-schemas, gtk3, makeDesktopItem }:
let pname = "zy";
    version = "2.7.1";
    desktopItem = makeDesktopItem {
      name = pname;
      desktopName = "ZY-Player";
      comment = "Network player";
      icon = "mpv";
      terminal = "false";
      exec = pname;
      categories = "Network;Player";
    };
in appimageTools.wrapType2 rec {
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/Hunlongyu/ZY-Player/releases/download/v${version}-HappyNewYear/ZY-Player-${version}-HappyNewYear.AppImage";
    sha512 = "Mn0ejIRIysHCl5ZkaC8dWT95uYJDhx6eOlw357rQJbQ3q8fnLrMcsQ5RTJ6SuUjHMIUd6VghjE3+X9usizDLlA==";
  };
  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  multiPkgs = null; # no 32bit needed
  extraPkgs = p:(appimageTools.defaultFhsEnvArgs.multiPkgs p);
  extraInstallCommands = ''
    mv $out/bin/{${name},${pname}}
    # chmod +x $out/bin/${pname}
    mkdir -p "$out/share/applications/"
    cp "${desktopItem}"/share/applications/* "$out/share/applications/"
    substituteInPlace $out/share/applications/*.desktop --subst-var out
  '';

  meta = with lib; {
    description = "跨平台桌面端视频资源播放器.简洁无广告.免费高颜值";
    homepage = http://zyplayer.fun/;
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ syl ];
  };
}
