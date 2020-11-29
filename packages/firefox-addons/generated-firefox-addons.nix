{ buildFirefoxXpiAddon, fetchurl, stdenv }:

{
  "ublock-origin" = buildFirefoxXpiAddon {
    pname = "ublock-origin";
    version = "1.31.0";
    addonId = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/3679754/ublock_origin-1.31.0-an+fx.xpi";
    sha256 = "d9eef701b99866565708fe69b5855c1634187630e9e223e810f10e482545e6c0";
    meta = with stdenv.lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
  };
}
