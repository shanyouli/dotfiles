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
      type = types.str;
      default = "";
      apply = v:
        if builtins.elem v browsers
        then v
        else "";
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
      modules.browser.firefox.enable = mkDefault (builtins.elem "firefox" [cfg.default cfg.fallback]);
      modules.browser.chrome.enable = mkDefault (builtins.elem "chrome" [cfg.default cfg.fallback]);
    }
    (mkIf (cfg.fallback != "") (
      let
        # browsers = ["firefox" "chrome" "chromium" "brave" "librewolf" "vivaldi"];
        package =
          if (! pkgs.stdenvNoCC.isDarwin)
          then
            if cfg.fallback == "brave"
            then [pkgs.brave]
            else if cfg.fallback == "vivaldi"
            then [pkgs.vivaldi]
            else if cfg.fallback == "chromium"
            then [pkgs.chromium]
            else []
          else [];
        fallback_browser =
          if (builtins.elem cfg.fallback ["firefox" "chrome"])
          then []
          else [cfg.fallback];
      in {
        user.packages = package;
        modules.shell.gopass.browsers = fallback_browser;
      }
    ))
  ];
}
