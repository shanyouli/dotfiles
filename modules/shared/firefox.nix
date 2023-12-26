{
  config,
  pkgs,
  lib,
  options,
  ...
}:
with lib;
with lib.my; let
  merge = lib.foldr (a: b: a // b) {};
  cfg = config.modules.firefox;
in {
  options.modules.firefox = with types; {
    enable = mkBoolOpt false;
    package = mkOption {
      type = types.package;
      default =
        if pkgs.stdenv.isLinux
        then pkgs.firefox
        else pkgs.firefox-esr-bin;
      defaultText = literalExample "pkgs.firefox";
      example = literalExample "pkgs.firefox";
      description = "The Firefox using";
    };
  };
  config = mkIf cfg.enable {
    home.programs.browserpass.enable = true;
    home.programs.browserpass.browsers = ["firefox" "chrome"];
    user.packages = [pkgs.geckodriver];
    home.programs.firefox = {
      enable = true;
      package = cfg.package;
      profiles = {
        default = {
          name = "Default";
          settings = merge [
            (import (configDir + "/firefox/annoyances.nix"))
            (import (configDir + "/firefox/browser-features.nix"))
            (import (configDir + "/firefox/privacy.nix"))
            (import (configDir + "/firefox/tracking.nix"))
            (import (configDir + "/firefox/security.nix"))
            {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "svg.context-properties.content.enabled" = true;
              "extensions.htmlaboutaddons.recommendations.enabled" = false; # 扩展页浏览器推荐
              # "image.mem.max_decoded_image_kb" = 51200;
              # "image.mem.min_discard_timeout_ms" =  10000;
              # "image.mem.surfacecache.max_size_kb" = 51200;
              # "image.mem.surfacecache.size_factor" = 32;
              # "javascript.options.mem.max" = 51200;
              # "javascript.options.mem.gc_frequency" = 10;
              # "javascript.options.mem.high_water_mark" = 16;
            }
          ];
          # userChrome = builtins.readFile (pkgs.fetchurl {
          #   url = "https://github.com/betterbrowser/arcfox/releases/download/2.4.3/userChrome.css";
          #   sha256 = "0x7ssvhiw843aff6xc462m90mqah6a6hzkqdnslw2q3aw121fkb6";
          # });
          # userChrome = builtins.readFile "${configDir}/firefox/userChrome.css";
          # userContent =
          #   builtins.readFile "${configDir}/firefox/userContent.css";
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            browserpass
            (buildFirefoxXpiAddon rec {
              pname = "sidebery";
              version = "5.0.0";
              url = "https://github.com/mbnuqw/sidebery/releases/download/v${version}/sidebery-${version}.1.xpi";
              addonId = "{3c078156-979c-498b-8990-85f7987dd929}";
              sha256 = "1ppvmg37734cdk44mx8bjd88la5gwjhd9ml86p352ajk4zgb2mwp";
              meta = {
                homepage = "https://github.com/mbnuqw/sidebery";
                description = "Firefox extension for managing tabs and bookmarks in sidebar.";
                license = licenses.mit;
              };
              platforms = platforms.all;
            })
            (buildFirefoxXpiAddon rec {
              pname = "download_with_aria2";
              version = "4.6.0";
              url = "https://addons.mozilla.org/firefox/downloads/file/4208616/download_with_aria2-4.6.0.2278.xpi";
              addonId = "firefox@downloadWithAria2";
              sha256 = "02im79290md7amrcycw7jay97w7sdhhc7b2048jsj648jjn01hyy";
              meta = {
                homepage = "https://github.com/jc3213/download_with_aria2";
                description = "Browser extension for aria2c json-rpc";
                license = licenses.mit;
              };
              platforms = platforms.all;
            })
            surfingkeys
            darkreader
            auto-tab-discard
            user-agent-string-switcher
            violentmonkey
            switchyomega
            stylus
            ublock-origin
          ];
        };

        # This does not have as strict privacy settings as the default profile.
        # It uses the default firefox settings. Useful when something is not
        # working using the default profile
        shit = {
          name = "crap";
          id = 1;
        };
      };
    };
  };
}
