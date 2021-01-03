{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.media.feeluown;
    cfgFile = "${configDir}/feeluown/.fuorc";
in {
  options.modules.desktop.media.feeluown = {
    enable = mkBoolOpt false;
    dataHome = mkBoolOpt true;
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.dataHome {
      user.packages = with pkgs; [
        (makeDesktopItem {
          name = "feeluown";
          desktopName = "FeelUOwn";
          icon = "${python3Packages.feeluown}/${python3Packages.python.sitePackages}/feeluown/feeluown.png";
          exec = "feeluown --log-to-file";
          categories = "AudioVideo;Audio;Player;Qt";
          terminal = "false";
          startupNotify = "true";
        })
        (writeScriptBin "feeluown" ''
           #!${pkgs.stdenv.shell}
           export HOME=${xdgData}/feeluown
           [[ -d $HOME ]] || mkdir -p $HOME
           exec ${pkgs.my.feeluown-full}/bin/feeluown "$@"
        '')
        (writeScriptBin "fuo" ''
          #!${pkgs.stdenv.shell}
          export HOME=${xdgData}/feeluown
          [[ -d $HOME ]] || mkdir -p $HOME
          exec ${pkgs.my.feeluown-full}/bin/fuo "$@"
       '')];
      home.dataFile."feeluown/.fuorc".source = "${cfgFile}";
    })
    (mkIf (! cfg.dataHome) {
      user.packages = [ pkgs.my.feeluown-full ];
      home.file.".fuorc".source = "${cfgFile}";
    })
  ]);
}
