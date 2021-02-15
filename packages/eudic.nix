{ stdenv, qt5, dpkg, makeWrapper, autoPatchelfHook, fetchurl
, alsaLib, e2fsprogs, fontconfig, freetype, fribidi, gdk_pixbuf, glib, gmp
, harfbuzz, libdrm, libjack2, libGL, libgpgerror, mesa, p11-kit, pango
, xorg, zlib, gst_all_1 }:
stdenv.mkDerivation rec {
  pname = "eudic";
  version = "20210206";
  src = fetchurl {
    url = "https://www.eudic.net/download/eudic.deb?v=2021-02-06";
    sha256 = "sha256-IKJ4ARCqQCTD3QAkFcbMRbm6YbIJyHRbry8vhhdysRE=";
    curlOpts = "-A 'Mozilla/5.0'";
  };
  unpackCmd = "${dpkg}/bin/dpkg -x $src .";
  sourceRoot = ".";

  nativeBuildInputs = [ qt5.wrapQtAppsHook makeWrapper autoPatchelfHook ];
  buildInputs = [
    alsaLib
    e2fsprogs
    fontconfig.lib
    freetype
    fribidi
    gdk_pixbuf
    glib
    gmp
    harfbuzz
    libdrm
    libjack2
    libGL
    libgpgerror
    mesa
    p11-kit
    pango
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libxcb
    xorg.libSM
    xorg.libICE
    zlib
  ];
  installPhase = ''
      mkdir -p $out/share
      cp -r usr/share/applications $out/share/applications
      cp -r usr/share/icons $out/share/icons
      cp -r usr/share/pixmaps $out/share/pixmaps

      mkdir -p $out/lib/eudic
      cp -r usr/lib $out/lib/eudic/libs
      cp -r usr/share/eusoft/lib/* $out/lib/eudic/libs
      cp -r usr/share/eusoft/*.so.* $out/lib/eudic/libs
      cp -r usr/share/eusoft/plugins $out/lib/eudic/plugins
      cp -r usr/share/eusoft/gstreamer-1.0 $out/lib/eudic/gstreamer-1.0

      mkdir -p $out/share/eudic
      cp -r usr/share/eusoft/dat $out/share/eudic/dat
      cp -r usr/share/eusoft/dic $out/share/eudic/dic
      cp -r usr/share/eusoft/translations $out/share/eudic/translations
      cp usr/share/eusoft/eudic $out/share/eudic/eudic

      mkdir -p $out/bin
      ln -sf $out/share/eudic/eudic $out/bin/eudic

      sed -i "s|/usr/share/eusoft/AppRun|eudic|g" $out/share/applications/eudic.desktop

    '';
  postFixup = ''
     wrapProgram $out/bin/eudic \
       --set GST_PLUGIN_SYSTEM_PATH "$out/lib/eudic/gstreamer-1.0/:${gst_all_1.gstreamer}/lib" \
       --set GST_PLUGIN_SCANNER "$out/lib/eudic/gstreamer-1.0/:${gst_all_1.gstreamer}/lib" \
       --set GST_PLUGIN_PATH "$out/lib/eudic/gstreamer-1.0/:${gst_all_1.gstreamer}/lib" \
       --set QT_PLUGIN_PATH "$out/lib/eudic/plugins" \
       --set QT_XKB_CONFIG_ROOT "${xorg.xkeyboardconfig}/share/X11/xkb" \
       --set XKB_CONFIG_ROOT "${xorg.xkeyboardconfig}/share/X11/xkb"
   '';
}
