{ lib, emacsPackages, fetchurl, fetchFromGitHub, pkgs, ... }: let
  inherit (emacsPackages) trivialBuild emacs;
in lib.recurseIntoAttrs rec {
  emacs-webkit = trivialBuild rec {
    pname = "emacs-webkit";
    version = "20201123";
    src = fetchFromGitHub {
      owner = "akirakyle";
      repo = "${pname}";
      rev = "790f7ad31324c16a0d659c7b8dfe9c2fb15ddabd";
      sha256 = "sha256-P13XGpV5apx0NHSD91qOl66/pLGEJe5E+fI1LHHMDs0=";
    };
    buildPhase = ''
      make all
      export LD_LIBRARY_PATH=$PWD:$LD_LIBRARY_PATH
    '';
    nativeBuildInputs = with pkgs; [ pkg-config wrapGAppsHook ];
    gstBuildInputs = with pkgs; with gst_all_1; [
      gstreamer gst-libav
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
    ];
    buildInputs = with pkgs; [
      webkitgtk
      glib gdk-pixbuf cairo
      mime-types pango gtk3
      glib-networking gsettings-desktop-schemas
      xclip notify-osd enchant
    ] ++ gstBuildInputs;

    GIO_EXTRA_MODULES = "${pkgs.glib-networking}/lib/gio/modules:${pkgs.dconf.lib}/lib/gio/modules";
    GST_PLUGIN_SYSTEM_PATH_1_0 = lib.concatMapStringsSep ":" (p: "${p}/lib/gstreamer-1.0") gstBuildInputs;
    postInstall = ''
      cp *.so *.js *.css $out/share/emacs/site-lisp/
      mkdir $out/lib && cp *.so $out/lib/
    '';
  };
}
