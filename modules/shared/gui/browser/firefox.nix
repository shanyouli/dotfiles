{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules.gui;
  cfg = cfm.browser.firefox;
  mozillaConfDir = cfm.browser.configDir.firefox;
  cfgConfDir =
    if pkgs.stdenvNoCC.isDarwin then
      "Library/Application Support/Firefox"
    else
      "${mozillaConfDir}/firefox";

  wrapPackage =
    package:
    let
      fcfg = { inherit (cfg) enableGnomeExtensions; };
    in
    if package == null then
      null
    else if pkgs.stdenvNoCC.isDarwin then
      package
    else
      package.override (old: {
        cfg = old.cfg or { } // fcfg;
      });
  extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

  profilePath = "${cfgConfDir}/Profiles/${lib.toLower cfg.profileName}";
in
{
  options.modules.gui.browser.firefox = {
    enable = mkEnableOption "Whether to using firefox";
    dev.enable = mkBoolOpt true;
    package = mkOption {
      type = with types; nullOr package;
      default = if pkgs.stdenvNoCC.isLinux then pkgs.firefox else pkgs.unstable.darwinapps.firefox;
      description = "The Firefox package to use. ";
    };
    finalPackage = mkOption {
      type = with types; nullOr package;
      readOnly = true;
      description = "Resulting Firefox package.";
    };
    profileName = mkOpt types.str "Default";
    settings =
      with types;
      mkOpt'
        (attrsOf (oneOf [
          bool
          int
          str
        ]))
        { }
        ''
          Firefox preferences to set in <filename>user.js</filename> or "mozilla.cfg"
        '';
    extraConfig =
      with types;
      mkOpt' lines "" ''
        Extra Lines to add to user.js or mozilla.cfg
      '';
    userChrome = with types; mkOpt' lines "" "CSS styles for Firefox's interface";
    userContent = with types; mkOpt' lines "" "Global CSS styles for websites";
    extensions = mkOption {
      type = with types; nullOr (listOf package);
      default = null;
      description = "Firefox addons packages.";
    };
    enableGnomeExtensions = mkOpt' types.bool false ''
      GnomeShell extensions, Note, you also need to set the NixOS option
      `services.gnome.gnome-browser-connector.enable` to `true`.
    '';
  };
  config = mkIf cfg.enable {
    modules = {
      gopass.browsers = [ "firefox" ];
      gui.browser.firefox = {
        extensions = mkDefault (
          with pkgs.unstable.firefox-addons;
          [
            (mkIf config.modules.gopass.enable browserpass-ce)
            noscript
            ublock-origin
            download-with-aria2
            sidebery
            surfingkeys_ff
            auto-tab-discard
            user-agent-string-switcher
            violentmonkey
            styl-us
            # immersive-translate # kiss-translator # 翻译插件,使用脚本取代
            chrome-mask
            zeroomega
          ]
        );
        finalPackage = wrapPackage cfg.package;
      };
    };
    home = {
      packages = [ cfg.finalPackage ] ++ optionals cfg.dev.enable [ pkgs.unstable.geckodriver ];
      file = mkMerge [
        {
          "${cfgConfDir}/profiles.ini".text = ''
            [General]
            StartWithLastProfile=1

            [Profile0]
            Default=1
            IsRelative=1
            Name=${cfg.profileName}
            Path=Profiles/${lib.toLower cfg.profileName}

            [Profile1]
            Default=0
            IsRelative=1
            Name=shit
            Path=Profiles/shit
          '';
          "${profilePath}/.keep".text = "";
          "${profilePath}/chrome/userChrome.css" = mkIf (cfg.userChrome != "") { text = cfg.userChrome; };
          "${profilePath}/chrome/userContent.css" = mkIf (cfg.userContent != "") { text = cfg.userContent; };
          "${profilePath}/user.js".text = ''
            ${builtins.readFile "${my.dotfiles.config}/firefox/user.js"}

            ${cfg.extraConfig}
          '';
          "${profilePath}/extensions" =
            mkIf
              (
                cfg.extensions != null
                || cfg.extensions != [ ]
                ||
                  ((builtins.typeOf cfg.extensions) == "set")
                  && (
                    !builtins.elem cfg.extensions.content [
                      null
                      [ ]
                    ]
                  )
              )
              {
                source =
                  let
                    extensionsEnvPkg = pkgs.buildEnv {
                      name = "my-firefox-extensions";
                      paths = cfg.extensions;
                    };
                  in
                  "${extensionsEnvPkg}/share/mozilla/${extensionPath}";
                recursive = true;
                force = true;
              };
        }
        (mkIf (cfg.userChrome == "") {
          "${profilePath}/chrome/userChrome.css".source =
            let
              name = if pkgs.stdenvNoCC.isDarwin then "userChrome-darwin.css" else "userChrome-linux.css";
            in
            "${my.dotfiles.config}/firefox/chrome/${name}";
        })
        {
          "${profilePath}/chrome/" = {
            source = "${pkgs.unstable.userChromeJS}";
            recursive = true;
          };
        }
      ];
    };
  };
}
