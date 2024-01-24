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
  cfg = cfm.macos.chrome;
in {
  options.modules.macos.chrome = {
    enable = mkEnableOption "Whether to google-chrome";
    dev.enable = mkEnableOption "Whether to chromedriver";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      # "google-chrome"
      # "arc" # next browser
      # "brave-browser"
      # "chromedriver" # brave 浏览器的driver
      homebrew.casks = ["google-chrome"];
    }
    (mkIf cfg.dev.enable {
      user.packages = [pkgs.chromedriver];
    })
  ]);
}
