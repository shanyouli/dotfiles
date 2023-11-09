{ buildFirefoxXpiAddon, fetchurl, stdenv }:

{
  "ublock-origin" = buildFirefoxXpiAddon {
    name = "ublock-origin";
    url = "https://addons.mozilla.org/firefox/downloads/file/3679754/ublock_origin-1.31.0-an+fx.xpi";
    sha256 = "d9eef701b99866565708fe69b5855c1634187630e9e223e810f10e482545e6c0";
  };

  "stylus" = buildFirefoxXpiAddon {
    name = "stylus";
    url = "https://addons.mozilla.org/firefox/downloads/file/3614089/stylus-1.5.14-fx.xpi";
    sha256 = "sha256-K7N55lUUTgMOyTG6s8oB8R7ocQtP94ihmXftlPd4oVk=";
  };
  "proxy-switchyomega" = buildFirefoxXpiAddon {
    name = "proxy-switchyomega";
    url = "https://addons.mozilla.org/firefox/downloads/file/1056777/proxy_switchyomega-2.5.20-an+fx.xpi";
    sha256 = "0f6a9hlgndgsdqwdzkv54ddng0izi87y5va10a8a204aj0gsc39n";
  };
  "surfingkeys" = buildFirefoxXpiAddon {
    name = "Surfingkeys";
    url = "https://addons.mozilla.org/firefox/downloads/file/3674805/surfingkeys-0.9.68-fx.xpi";
    sha256 = "1q0a8bf5bv8j4qbbdg6iijgiqhm18s3ixj2hbvsq06ly405ah968";
  };
#   "gitako" = buildFirefoxXpiAddon {
#     pname = "gitako";
#     version = "2.4.3";
#     addonId = "{983bd86b-9d6f-4394-92b8-63d844c4ce4c}";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3685782/gitako_github_file_tree-2.4.3-fx.xpi";
#     sha256 = "0j3f4bfc08d8dcm9zlbhgwk2gfyyxabl4cd2nlgbsd0hvf29bd4f";
#     meta = with stdenv.lib; {
#       homepage = "https://github.com/EnixCoda/Gitako";
#       description = "Gitako is a file tree extension for GitHub, available on Firefox, Chrome, and Edge.";
#       platforms = platforms.all;
#     };
#   };
  "darkreader" = buildFirefoxXpiAddon {
    name = "darkreader";
    url = "https://addons.mozilla.org/firefox/downloads/file/3684946/dark_reader-4.9.26-an+fx.xpi";
    sha256 = "5f2a2449524f5ab05c2e8568d2678c6b25795e87ce77ebc9448e13e8184e3c5f";
  };
  "aria2-manager" = buildFirefoxXpiAddon {
    name = "aria2-manager";
    url = "https://addons.mozilla.org/firefox/downloads/file/3690967/aria2_manager-1.2.8-an+fx.xpi";
    sha256 = "0zvz48g1pnx2qr6k2d6gjayvvjdpgbqccaqwbdw6iixgqj578wds";
  };
  "save-page" = buildFirefoxXpiAddon {
    name = "save-page-we";
    url = "https://addons.mozilla.org/firefox/downloads/file/3680987/save_page_we-23.7-fx.xpi";
    sha256 = "1613015d08a801c70fe77e7d5ba028c87cf70e1adc11f393aaf5dcd090c99fa5";
  };
#   "simplifyGmail" = buildFirefoxXpiAddon  {
#     pname = "simplify-gmail";
#     version = "1.7.20";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3673021/simplify_gmail-1.7.20-fx.xpi";
#     sha256 = "12hs2x0mfl5wc9pixmkprxf0ghnbg11zd6qclb0scgh8i03vpvrx";
#     meta = with stdenv.lib; {
#       description = "Beautify GMAIL interface";
#       platforms = platforms.all;
#     };
#     addonId = "{a4c1064c-95dd-47a7-9b02-bb30213b7b29}";
#   };
#   "epubReader" = buildFirefoxXpiAddon {
#     pname = "epubReader";
#     version = "2.0.13";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3594370/epubreader-2.0.13-fx.xpi";
#     sha256 = "0v649d381zsa36amzxldscpi0ih6c72ax2bc7xxw753ia5h4ca9a";
#     meta = with stdenv.lib; {
#       description = "EPUB Reader";
#       platforms = platforms.all;
#     };
#     addonId = "{5384767E-00D9-40E9-B72F-9CC39D655D6F}";
#   };
#   "keePassXC-Browser" = buildFirefoxXpiAddon {
#     pname = "KeePassXC-Browser";
#     version = "1.7.3";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3673941/keepassxc_browser-1.7.3-fx.xpi";
#     sha256 = "10br9rq108c80kb8160brqdfa2m9gw0zpb42cdrv23vybbcz6f78";
#     meta = with stdenv.lib; {
#       description = "Official browser plugin for the KeePassXC password manager";
#       platforms = platforms.all;
#     };
#     addonId = "keepassxc-browser@keepassxc.org";
#   };
#   "better-history" = buildFirefoxXpiAddon {
#     pname = "better-history";
#     version = "1.0.0";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3643810/better_history-1.0.0-an+fx.xpi";
#     sha256 = "0w9qmrda1gm7k4l9a6smdn0bsn42424l4gpvvvvm98cj1pvavzfc";
#     meta = with stdenv.lib; {
#       description = "Better display hostory";
#       platforms = platforms.all;
#     };
#     addonId = "{955787d0-eb12-4903-86bc-0f8c49545c68}";
#   };
#   "violentmonkey" = buildFirefoxXpiAddon {
#     pname = "Violentmonkey";
#     version = "2.12.7";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3505281/violentmonkey-2.12.7-an+fx.xpi";
#     sha256 = "1yr5040yxkzz2jgm5v183cipqn07piynd7frjpj7k2s8pkbka4im";
#     meta = with stdenv.lib; {
#       homepage = "https://violentmonkey.github.io/";
#       description = "Scripting management";
#       plaforms = platforms.all;
#     };
#     addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
#   };
#   "mobiReader" = buildFirefoxXpiAddon {
#     pname = "Mobi-Reader";
#     version = "0.1.2";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3497667/mobi_reader-0.1.2-an+fx.xpi";
#     sha256 = "046hh0bdpvn0w1n7vizpicxnlc59k13l6lskk1p7zmfqh2frchxh";
#     meta = with stdenv.lib; {
#       description = "MOBI Reader";
#       platforms = platforms.all;
#     };
#     adonId = "{93518c51-19b2-4adb-8958-17dfcfe959b4}";
#   };
#   "inMyPocket" = buildFirefoxXpiAddon {
#     pname = "inMyPocket";
#     version = "0.11.9";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3674044/in_my_pocket-0.11.9-fx.xpi";
#     sha256 = "0wb07bn39f5dpx2qwm2ilxq7rgvfq60rpp40hnzyvlga9c9b51w7";
#     meta = with stdenv.lib; {
#       description = "My Pocket";
#       platforms = platforms.all;
#     };
#     addonId =  "{cd7e22de-2e34-40f0-aeff-cec824cbccac}";
#   };
#   "autoTabDiscard" = buildFirefoxXpiAddon {
#     pname = "autoTabDiscard";
#     version = "0.3.7";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3610821/auto_tab_discard-0.3.7-an+fx.xpi";
#     sha256 = "0vsg82fswn68n2kkbhvl32fgsj5vkjfpi4bgawi41wb381fi87cd";
#     meta = with stdenv.lib; {
#       description = "Auto Tab Discard";
#       platforms = platforms.all;
#     };
#     addonId = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
#   };
#   "tileTabsWE" = buildFirefoxXpiAddon {
#     pname = "tileTabsWE";
#     version = "13.2";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3683242/tile_tabs_we-13.2-fx.xpi";
#     sha256 = "08qgd7kw05ya7n3i32zsm1n0fdgnf0wmj8s6hss3zblwbw5ikfhj";
#     addonId = "tiletabs-we@DW-dev";
#     meta = with stdenv.lib; {
#       description = "Tile Tabs WE";
#       platforms = platforms.all;
#     };
#   };
#   "saladict" = buildFirefoxXpiAddon {
#     pname = "saladict";
#     version = "7.18.0";
#     url = "https://addons.mozilla.org/firefox/downloads/file/3670878/_-7.18.0-fx.xpi";
#     addonId = "saladict@crimx.com";
#     meta = with stdenv.lib; {
#       description = "dictionary";
#       platforms = platforms.all;
#     };
#     sha256 = "09vq7yvbysa0355vhpr55fwsiy5g4jm4mc16f0m63sv4q3k7ks71";
#   };
  "passff" = buildFirefoxXpiAddon {
    name = "passff";
    fixedExtid = "passff@invicem.pro";
    url = "https://addons.mozilla.org/firefox/downloads/file/3685893/passff-1.10.4-fx.xpi";
    sha256 = "047icalivyw06ximhc688ilva62yzljylww7cy4pzim0zyz9h4z3";
  };
}
