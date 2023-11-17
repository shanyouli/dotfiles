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
  cfg = config.my.modules.firefox;
in {
  options.my.modules.firefox = with types; {
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
    my.programs.browserpass.enable = true;
    my.programs.browserpass.browsers = ["firefox" "chrome"];
    my.user.packages = [pkgs.geckodriver];
    my.programs.firefox = {
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
          # userChrome = builtins.readFile "${configDir}/firefox/userChrome.css";
          # userContent =
          #   builtins.readFile "${configDir}/firefox/userContent.css";
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            browserpass
            surfingkeys
            darkreader
            auto-tab-discard
            # stylus
            # user-agent-string-switcher
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
