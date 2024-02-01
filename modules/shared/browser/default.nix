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
in {
  options.modules.browser = {
    default = mkStrOpt "firefox";
    fallback = with types; mkOpt' (oneOf [str package]) "" ''A spare tire browser'';
  };
  config = mkMerge [
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
    {
      user.packages = [(mkIf ((builtins.typeOf cfg.fallback) != "string") cfg.fallback)];
    }
  ];
}
