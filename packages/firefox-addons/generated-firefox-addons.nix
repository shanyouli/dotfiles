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

  "stylus" = buildFirefoxXpiAddon {
    pname = "stylus";
    version = "1.5.14";
    addonId = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3614089/stylus-1.5.14-fx.xpi";
    sha256 = "sha256-K7N55lUUTgMOyTG6s8oB8R7ocQtP94ihmXftlPd4oVk=";
    meta = with stdenv.lib;
      {
        homepage = "https://add0n.com/stylus.html";
        description = "Redesign your favorite websites with Stylus, an actively developed and community driven userstyles manager. Easily install custom themes from popular online repositories, or create, edit, and manage your own personalized CSS stylesheets.";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
  };
  "foxyproxy-standard" = buildFirefoxXpiAddon {
    pname = "foxyproxy-standard";
    version = "7.5.1";
    addonId = "foxyproxy@eric.h.jung";
    url = "https://addons.mozilla.org/firefox/downloads/file/3616824/foxyproxy_standard-7.5.1-an+fx.xpi";
    sha256 = "42109bc250e20aafd841183d09c7336008ab49574b5e8aa9206991bb306c3a65";
    meta = with stdenv.lib;
      {
        homepage = "https://getfoxyproxy.org";
        description = "FoxyProxy is an advanced proxy management tool that completely replaces Firefox's limited proxying capabilities. For a simpler tool and less advanced configuration options, please use FoxyProxy Basic.";
        license = licenses.gpl2;
        platforms = platforms.all;
      };
  };
  "proxy-switchyomega" = buildFirefoxXpiAddon {
    pname = "proxy-switchyomega";
    version = "2.5.20";
    addonId = "switchyomega@feliscatus.addons.mozilla.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/1056777/proxy_switchyomega-2.5.20-an+fx.xpi";
    sha256 = "0f6a9hlgndgsdqwdzkv54ddng0izi87y5va10a8a204aj0gsc39n";
    meta = with stdenv.lib; {
      homepage = "https://github.com/FelisCatus/SwitchyOmega";
      description = "Proxy Tools";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  };
  "surfingkeys" = buildFirefoxXpiAddon {
    pname = "Surfingkeys";
    version = "0.9.68";
    addonId = "{a8332c60-5b6d-41ee-bfc8-e9bb331d34ad}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3674805/surfingkeys-0.9.68-fx.xpi";
    sha256 = "1q0a8bf5bv8j4qbbdg6iijgiqhm18s3ixj2hbvsq06ly405ah968";
    meta = with stdenv.lib; {
      homepage = "https://github.com/brookhong/Surfingkeys";
      description = ''
        Rich shortcuts for you to click links / switch tabs / scroll pages or
        DIVs / capture full page or DIV etc, let you use the browser like vim,
        plus an embed vim editor.
      '';
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
  "tabSessionManager" = buildFirefoxXpiAddon {
    pname = "tab-session-manager";
    version = "6.3.0";
    addonId = "Tab-Session-Manager@sienori";
    url = "https://addons.mozilla.org/firefox/downloads/file/3673996/tab_session_manager-6.3.0-fx.xpi";
    sha256 = "1ri42b5a5d3908m1mic14irncx3jray6djqsgmk1cb4b9ncsfx3m";
    meta = with stdenv.lib; {
      homepage = "https://github.com/sienori/Tab-Session-Manager";
      description = "Save and restore the state of windows and tabs. It also supports automatic saving and cloud sync.";
      platforms = platforms.all;
    };
  };
  "gitako" = buildFirefoxXpiAddon {
    pname = "gitako";
    version = "2.4.3";
    addonId = "{983bd86b-9d6f-4394-92b8-63d844c4ce4c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3685782/gitako_github_file_tree-2.4.3-fx.xpi";
    sha256 = "0j3f4bfc08d8dcm9zlbhgwk2gfyyxabl4cd2nlgbsd0hvf29bd4f";
    meta = with stdenv.lib; {
      homepage = "https://github.com/EnixCoda/Gitako";
      description = "Gitako is a file tree extension for GitHub, available on Firefox, Chrome, and Edge.";
      platforms = platforms.all;
    };
  };
  "darkreader" = buildFirefoxXpiAddon {
    pname = "darkreader";
    version = "4.9.26";
    addonId = "addon@darkreader.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3684946/dark_reader-4.9.26-an+fx.xpi";
    sha256 = "5f2a2449524f5ab05c2e8568d2678c6b25795e87ce77ebc9448e13e8184e3c5f";
    meta = with stdenv.lib;
      {
        homepage = "https://darkreader.org/";
        description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing.";
        license = licenses.mit;
        platforms = platforms.all;
      };
  };
  "aria2-gui" = buildFirefoxXpiAddon {
    pname = "ari2-gui";
    version = "0.4.5";
    addonId = "{e2488817-3d73-4013-850d-b66c5e42d505}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3025850/aria2_download_manager_integration-0.4.5-fx.xpi";
    sha256 = "09hg8625ywy32zam74p9n9ysqcb4a2mvlj2q3ld9sjb0k1pqcwhn";
    meta = with stdenv.lib; {
      homepage = "https://github.com/RossWang/Aria2-Integration";
      description = "Aria2 Download Manager Integration";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
  "copy-all-tab-urls" = buildFirefoxXpiAddon {
    pname = "copy-all-tab-urls";
    version = "2.0.2";
    url = "https://addons.mozilla.org/firefox/downloads/file/3521129/copy_all_tab_urls-2.0.2-fx.xpi";
    sha256 = "1k643m5pg75hlczsvcbyi3d0mjzs66bv7kizhpq111s7gkf71q7k";
    meta = with stdenv.lib; {
      homepage = "https://addons.mozilla.org/en-US/firefox/addon/copy-all-tab-urls-we";
      description = "Copy all tab Urls";
      platforms = platforms.all;
    };
    addonId = "{0507f777-2480-4d48-baf1-3b9c8feeb2b4}";
  };
  "save-page-we" = buildFirefoxXpiAddon {
    pname = "save-page-we";
    version = "23.7";
    addonId = "savepage-we@DW-dev";
    url = "https://addons.mozilla.org/firefox/downloads/file/3680987/save_page_we-23.7-fx.xpi";
    sha256 = "1613015d08a801c70fe77e7d5ba028c87cf70e1adc11f393aaf5dcd090c99fa5";
    meta = with stdenv.lib;
      {
        description = "Save a complete web page (as currently displayed) as a single HTML file that can be opened in any browser. Save a single page, multiple selected pages or a list of page URLs. Automate saving from command line.";
        license = licenses.gpl2;
        platforms = platforms.all;
      };
  };
  "simplifyGmail" = buildFirefoxXpiAddon  {
    pname = "simplify-gmail";
    version = "1.7.20";
    url = "https://addons.mozilla.org/firefox/downloads/file/3673021/simplify_gmail-1.7.20-fx.xpi";
    sha256 = "12hs2x0mfl5wc9pixmkprxf0ghnbg11zd6qclb0scgh8i03vpvrx";
    meta = with stdenv.lib; {
      description = "Beautify GMAIL interface";
      platforms = platforms.all;
    };
    addonId = "{a4c1064c-95dd-47a7-9b02-bb30213b7b29}";
  };
  "videoDownloadHelper" = buildFirefoxXpiAddon {
    pname = "video-DonwloadHelper";
    version = "7.3.9";
    url = "https://addons.mozilla.org/firefox/downloads/file/3534334/video_downloadhelper-7.3.9-an+fx.xpi";
    sha256 = "0vzwndz5qwkbsl451ndfz6z1gvk684prax26rwjckpl47lw876ql";
    meta = with stdenv.lib; {
      description = "Video Download Helper";
      platforms = platforms.all;
    };
    addonId = "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}";
  };
  "epubReader" = buildFirefoxXpiAddon {
    pname = "epubReader";
    version = "2.0.13";
    url = "https://addons.mozilla.org/firefox/downloads/file/3594370/epubreader-2.0.13-fx.xpi";
    sha256 = "0v649d381zsa36amzxldscpi0ih6c72ax2bc7xxw753ia5h4ca9a";
    meta = with stdenv.lib; {
      description = "EPUB Reader";
      platforms = platforms.all;
    };
    addonId = "{5384767E-00D9-40E9-B72F-9CC39D655D6F}";
  };
  "keePassXC-Browser" = buildFirefoxXpiAddon {
    pname = "KeePassXC-Browser";
    version = "1.7.3";
    url = "https://addons.mozilla.org/firefox/downloads/file/3673941/keepassxc_browser-1.7.3-fx.xpi";
    sha256 = "10br9rq108c80kb8160brqdfa2m9gw0zpb42cdrv23vybbcz6f78";
    meta = with stdenv.lib; {
      description = "Official browser plugin for the KeePassXC password manager";
      platforms = platforms.all;
    };
    addonId = "keepassxc-browser@keepassxc.org";
  };
  "better-history" = buildFirefoxXpiAddon {
    pname = "better-history";
    version = "1.0.0";
    url = "https://addons.mozilla.org/firefox/downloads/file/3643810/better_history-1.0.0-an+fx.xpi";
    sha256 = "0w9qmrda1gm7k4l9a6smdn0bsn42424l4gpvvvvm98cj1pvavzfc";
    meta = with stdenv.lib; {
      description = "Better display hostory";
      platforms = platforms.all;
    };
    addonId = "{955787d0-eb12-4903-86bc-0f8c49545c68}";
  };
  "violentmonkey" = buildFirefoxXpiAddon {
    pname = "Violentmonkey";
    version = "2.12.7";
    url = "https://addons.mozilla.org/firefox/downloads/file/3505281/violentmonkey-2.12.7-an+fx.xpi";
    sha256 = "1yr5040yxkzz2jgm5v183cipqn07piynd7frjpj7k2s8pkbka4im";
    meta = with stdenv.lib; {
      homepage = "https://violentmonkey.github.io/";
      description = "Scripting management";
      plaforms = platforms.all;
    };
    addonId = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
  };
  "draculaDarkTheme" = buildFirefoxXpiAddon {
    pname = "dracula-dark-theme";
    version = "1.9.1";
    url = "https://addons.mozilla.org/firefox/downloads/file/3554827/dracula_dark_theme-1.9.1-an+fx.xpi";
    sha256 = "1zf7cnys0vxqa5wy7jpbma6793h6xjff9anlpnlrkhijkjcx0rq9";
    meta = with stdenv.lib; {
      homepage = "https://draculatheme.com/firefox";
      description = "Dracula Dark Theme";
      plaforms = platforms.all;
    };
    addonId = "{b743f56d-1cc1-4048-8ba6-f9c2ab7aa54d}";
  };
  "mobiReader" = buildFirefoxXpiAddon {
    pname = "Mobi-Reader";
    version = "0.1.2";
    url = "https://addons.mozilla.org/firefox/downloads/file/3497667/mobi_reader-0.1.2-an+fx.xpi";
    sha256 = "046hh0bdpvn0w1n7vizpicxnlc59k13l6lskk1p7zmfqh2frchxh";
    meta = with stdenv.lib; {
      description = "MOBI Reader";
      platforms = platforms.all;
    };
    adonId = "{93518c51-19b2-4adb-8958-17dfcfe959b4}";
  };
  "inMyPocket" = buildFirefoxXpiAddon {
    pname = "inMyPocket";
    version = "0.11.9";
    url = "https://addons.mozilla.org/firefox/downloads/file/3674044/in_my_pocket-0.11.9-fx.xpi";
    sha256 = "0wb07bn39f5dpx2qwm2ilxq7rgvfq60rpp40hnzyvlga9c9b51w7";
    meta = with stdenv.lib; {
      description = "My Pocket";
      platforms = platforms.all;
    };
    addonId =  "{cd7e22de-2e34-40f0-aeff-cec824cbccac}";
  };
  "autoTabDiscard" = buildFirefoxXpiAddon {
    pname = "autoTabDiscard";
    version = "0.3.7";
    url = "https://addons.mozilla.org/firefox/downloads/file/3610821/auto_tab_discard-0.3.7-an+fx.xpi";
    sha256 = "0vsg82fswn68n2kkbhvl32fgsj5vkjfpi4bgawi41wb381fi87cd";
    meta = with stdenv.lib; {
      description = "Auto Tab Discard";
      platforms = platforms.all;
    };
    addonId = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
  };
  "tileTabsWE" = buildFirefoxXpiAddon {
    pname = "tileTabsWE";
    version = "13.2";
    url = "https://addons.mozilla.org/firefox/downloads/file/3683242/tile_tabs_we-13.2-fx.xpi";
    sha256 = "08qgd7kw05ya7n3i32zsm1n0fdgnf0wmj8s6hss3zblwbw5ikfhj";
    addonId = "tiletabs-we@DW-dev";
    meta = with stdenv.lib; {
      description = "Tile Tabs WE";
      platforms = platforms.all;
    };
  };
  "saladict" = buildFirefoxXpiAddon {
    pname = "saladict";
    version = "7.18.0";
    url = "https://addons.mozilla.org/firefox/downloads/file/3670878/_-7.18.0-fx.xpi";
    addonId = "saladict@crimx.com";
    meta = with stdenv.lib; {
      description = "dictionary";
      platforms = platforms.all;
    };
    sha256 = "09vq7yvbysa0355vhpr55fwsiy5g4jm4mc16f0m63sv4q3k7ks71";
  };
  "passff" = buildFirefoxXpiAddon {
    pname = "passff";
    version = "1.10.4";
    url = "https://addons.mozilla.org/firefox/downloads/file/3685893/passff-1.10.4-fx.xpi";
    addonId = "passff@invicem.pro";
    meta = with stdenv.lib; {
      description = "password store extensions.";
      platforms = platforms.all;
    };
    sha256 = "047icalivyw06ximhc688ilva62yzljylww7cy4pzim0zyz9h4z3";
  };
}
