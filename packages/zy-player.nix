{ appimageTools, fetchurl, lib, gsettings-desktop-schemas, gtk3 }:
# A great Player
# code from: @https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/office/timeular/default.nix
let
  inherit (appimageTools) extractType2 wrapType2;
  pname = "zy";
  version = "2.7.3";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/Hunlongyu/ZY-Player/releases/download/v${version}/ZY-Player-${version}.AppImage";
    sha256 = "1v2as2mmzxjcdlg02nlqg5jmwrsqlr20caigw62as0wg4lb81csh";
  };
  appimageContents = extractType2 { inherit name src; };
in wrapType2 rec {
  inherit name src;
  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  multiPkgs = null; # no 32bit needed
  extraPkgs = p:(appimageTools.defaultFhsEnvArgs.multiPkgs p);
  extraInstallCommands = ''
    mv $out/bin/{${name},${pname}}
    # chmod +x $out/bin/${pname}
    install -m 444 -D ${appimageContents}/zy.desktop $out/share/applications/zy.desktop
    substituteInPlace $out/share/applications/zy.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
    substituteInPlace $out/share/applications/zy.desktop --replace 'Icon=zy' 'Icon=${appimageContents}/zy.png'
  '';

  meta = with lib; {
    description = "跨平台桌面端视频资源播放器.简洁无广告.免费高颜值";
    homepage = http://zyplayer.fun/;
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ syl ];
  };
}
