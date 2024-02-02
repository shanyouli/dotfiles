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
    nativeHosts = with types; mkOpt (attrsOf (either str path)) {};
  };
  config = mkMerge [
    {
      modules.browser.nativeHosts = builtins.listToAttrs (map (n: {
          name = n;
          value =
            if n == "brave"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts"
              else ".config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
            else if n == "chrome"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/Google/Chrome/NativeMessagingHosts"
              else ".config/google-chrome/NativeMessagingHosts"
            else if n == "chromium"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/Chromium/NativeMessagingHosts"
              else ".config/chromium/NativeMessagingHosts"
            else if n == "firefox"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/Mozilla/NativeMessagingHosts"
              else ".mozilla/native-messaging-hosts"
            else if n == "librewolf"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/LibreWolf/NativeMessagingHosts"
              else ".librewolf/native-messaging-hosts"
            else if n == "vivaldi"
            then
              if pkgs.stdenv.isDarwin
              then "Library/Application Support/Vivaldi/NativeMessagingHosts"
              else ".config/vivaldi/NativeMessagingHosts"
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
