{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules.gui;
  cfg = cfm.browser;
  browsers = [
    "firefox"
    "chrome"
    "chromium"
    "brave"
    "librewolf"
    "vivaldi"
  ];
in
{
  options.modules.gui.browser = {
    default = mkOption {
      type = types.str;
      default = "";
      apply =
        str:
        if
          builtins.elem str [
            "chrome"
            "firefox"
          ]
        then
          str
        else
          "";
      description = "Default Browser";
    };
    fallback = mkOption {
      type = types.str;
      default = "";
      apply = v: if builtins.elem v browsers then v else "";
      description = "FallBack browser";
    };
    configDir = with types; mkOpt (attrsOf (either str path)) { };
  };
  config = mkMerge [
    {
      modules.gui.browser = {
        configDir = builtins.listToAttrs (
          map (n: {
            name = n;
            value =
              if n == "brave" then
                if pkgs.stdenv.hostPlatform.isDarwin then
                  "Library/Application Support/BraveSoftware/Brave-Browser"
                else
                  ".config/BraveSoftware/Brave-Browser"
              else if n == "chrome" then
                if pkgs.stdenv.hostPlatform.isDarwin then
                  "Library/Application Support/Google/Chrome"
                else
                  ".config/google-chrome"
              else if n == "chromium" then
                if pkgs.stdenv.hostPlatform.isDarwin then
                  "Library/Application Support/Chromium"
                else
                  ".config/chromium"
              else if n == "firefox" then
                if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support/Mozilla" else ".mozilla"
              else if n == "librewolf" then
                if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support/LibreWolf" else ".librewolf"
              else if n == "vivaldi" then
                if pkgs.stdenv.hostPlatform.isDarwin then
                  "Library/Application Support/Vivaldi"
                else
                  ".config/vivaldi"
              else
                throw "unknown browser ${n}";
          }) browsers
        );
        firefox.enable = mkDefault (
          builtins.elem "firefox" [
            cfg.default
            cfg.fallback
          ]
        );
        chrome.enable = mkDefault (
          builtins.elem "chrome" [
            cfg.default
            cfg.fallback
          ]
        );
      };
    }
    (mkIf (cfg.fallback != "") (
      let
        # browsers = ["firefox" "chrome" "chromium" "brave" "librewolf" "vivaldi"];
        package =
          if (!pkgs.stdenvNoCC.isDarwin) then
            if cfg.fallback == "brave" then
              [ pkgs.brave ]
            else if cfg.fallback == "vivaldi" then
              [ pkgs.vivaldi ]
            else if cfg.fallback == "chromium" then
              [ pkgs.chromium ]
            else
              [ ]
          else
            [ ];
        fallback_browser =
          if
            (builtins.elem cfg.fallback [
              "firefox"
              "chrome"
            ])
          then
            [ ]
          else
            [ cfg.fallback ];
      in
      {
        home.packages = package;
        modules.gopass.browsers = fallback_browser;
      }
    ))
    (mkIf (cfg.chrome.enable || cfg.firefox.enable) {
      modules.nginx.config = ''
        location /surfingkeys.js {
           charset utf-8;
           alias ./www/surfingkeys.js;
        }
      '';
      my.user.init.init-surfingkeys = ''
        let nginx_work_dir = "${config.modules.nginx.workDir}" | path join "www"
        let sufingkeys_js = "${my.dotfiles.config}" | path join "firefox/surfingkeys.js"
        mkdir $nginx_work_dir
        if ( $nginx_work_dir | path join "surfingkeys.js" | path exists) {
          mv ($nginx_work_dir | path join "surfingkeys.js") ($nginx_work_dir | path join "surfingkeys.js.backup")
        }
        ln -st $nginx_work_dir $sufingkeys_js
      '';
    })
  ];
}
