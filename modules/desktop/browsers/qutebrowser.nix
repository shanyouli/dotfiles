# modules/browser/qutebrowser.nix --- https://github.com/qutebrowser/qutebrowser
#
# Qutebrowser is cute because it's not enough of a browser to be handsome.
# Still, we can all tell he'll grow up to be one hell of a lady-killer.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.browsers.qutebrowser;
    pkg = pkgs.qutebrowser;
in {
  options.modules.desktop.browsers.qutebrowser = with types; {
    enable = mkBoolOpt false;
    userStyles = mkOpt lines "";
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      pkg
      (makeDesktopItem {
        name = "qutebrowser-private";
        desktopName = "Qutebrowser (Private)";
        genericName = "Open a private Qutebrowser window";
        icon = "qutebrowser";
        exec = ''${pkg}/bin/qutebrowser ":open -p"'';
        categories = "Network";
      })
      # unstable.python4Packages.adblock
    ];

    home = {
      configFile."qutebrowser/greasemonkey" = {
        source = "${configDir}/qutebrowser/greasemonkey";
        recursive = true;
      };
      dataFile."qutebrowser/userstyles.css".text = cfg.userStyles;
      configFile."qutebrowser/config.py".text = let
        baseFile = lib.readFile "${configDir}/qutebrowser/config.py";
        proxy = config.modules.proxy.httpPort ;
      in ''
        ${baseFile}
        ${optionalString ( proxy != null ) ''
          c.content.proxy = "http://127.0.0.1:${toString proxy}"
        ''}
      '';
    };
  };
}
