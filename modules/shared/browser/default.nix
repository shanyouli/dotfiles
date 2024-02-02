{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.browser;
  browsers = ["firefox" "chrome" "chromium" "brave" "librewolf" "vivaldi"];
in {
  options.modules.browser = {
    default = mkOption {
      type = types.str;
      default = "";
      apply = str:
        if builtins.elem str ["chrome" "firefox"]
        then str
        else "";
      description = "Default Browser";
    };
    fallback = mkOption {
      type = types.oneOf [types.str types.package];
      default = "";
      apply = v:
        if ((builtins.typeOf v) == "string") && (! (builtins.elem v ["chrome" "firefox"]))
        then ""
        else v;
      description = "FallBack browser";
    };
    configDir = with types; mkOpt (attrsOf (either str path)) {};
  };
  config = mkMerge [
    {
      modules.browser.configDir = builtins.listToAttrs (map (n: {
          name = n;
          value =
            if n == "brave"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/BraveSoftware/Brave-Browser"
              else ".config/BraveSoftware/Brave-Browser"
            else if n == "chrome"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/Google/Chrome"
              else ".config/google-chrome"
            else if n == "chromium"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/Chromium"
              else ".config/chromium"
            else if n == "firefox"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/Mozilla"
              else ".mozilla"
            else if n == "librewolf"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/LibreWolf"
              else ".librewolf"
            else if n == "vivaldi"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/Vivaldi"
              else ".config/vivaldi"
            else throw "unknown browser ${n}";
        })
        browsers);
    }
    (mkIf ((builtins.typeOf cfg.fallback) != "string") (let
      pkgsPname =
        if builtins.hasAttr "pname" cfg.fallback
        then cfg.fallback.pname
        else "";
      hostList =
        if builtins.elem pkgsPname browsers
        then [pkgsPname]
        else [];
    in {
      user.packages = [cfg.fallback];
      modules.shell.gopass.browsers = hostList;
    }))
    (
      mkIf (builtins.elem "firefox" [cfg.default cfg.fallback]) {
        modules.browser.firefox.enable = mkDefault true;
      }
    )
    (
      mkIf (builtins.elem "chrome" [cfg.default cfg.fallback]) {
        modules.browser.chrome.enable = mkDefault true;
        modules.browser.chrome.useBrew = mkDefault pkgs.stdenvNoCC.isDarwin;
      }
    )
  ];
}
