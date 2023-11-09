{stdenv, alsaLib, e2fsprogs, expat, freetype, fontconfig, keyutils, gdk_pixbuf
, glib, libGL, libgpgerror, libusb, libthai, p11-kit, pango, qt5, xorg, zlib
, harfbuzz, libdrm, libuuid
, makeWrapper, autoPatchelfHook, dpkg, fetchurl, }:
stdenv.mkDerivation rec {
    pname = "netease-cloud-music";
    version = "1.2.1";
    src = fetchurl {
      url = "http://d1.music.126.net/dmusic/${pname}_${version}_amd64_ubuntu_20190428.deb";
      sha256 = "sha256-HunwKELmwsjHnEiy6TIHT5whOo60I45eY/IEOFYv7Ls=";
      curlOpts = "-A 'Mozilla/5.0'";
    };
    unpackCmd = "${dpkg}/bin/dpkg -x $src .";
    sourceRoot = ".";

    nativeBuildInputs = [ qt5.wrapQtAppsHook makeWrapper autoPatchelfHook ];
    buildInputs = [
      alsaLib
      e2fsprogs
      expat
      fontconfig.lib
      freetype
      keyutils
      gdk_pixbuf
      glib
      harfbuzz
      libdrm
      libGL
      libgpgerror
      libusb
      libuuid
      libthai
      p11-kit
      pango
      qt5.qtbase
      qt5.qtwebchannel
      stdenv.cc.cc.lib
      xorg.libX11
      xorg.libxcb
      xorg.libXext
      xorg.libSM
      xorg.libICE
      zlib
    ];
    installPhase = ''
      mkdir -p $out/share
      cp -r usr/share/* $out/share

      mkdir -p $out/lib/netease-cloud-music
      cp -r opt/netease/netease-cloud-music/libs $out/lib/netease-cloud-music
      cp -r opt/netease/netease-cloud-music/plugins $out/lib/netease-cloud-music

      mkdir -p $out/bin
      cp opt/netease/netease-cloud-music/netease-cloud-music $out/bin/netease-cloud-music
    '';
   postFixup = ''
     wrapProgram $out/bin/netease-cloud-music \
       --set QT_PLUGIN_PATH "$out/lib/netease-cloud-music/plugins" \
       --set QT_QPA_PLATFORM_PLUGIN_PATH "$out/lib/netease-cloud-music/plugins/platforms" \
       --set QCEF_INSTALL_PATH "$out/lib/netease-cloud-music/libs/qcef" \
      --set QT_XKB_CONFIG_ROOT "${xorg.xkeyboardconfig}/share/X11/xkb"
   '';
  }
