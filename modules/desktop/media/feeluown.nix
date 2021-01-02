{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.media.feeluown;
in {
  options.modules.desktop.media.feeluown = {
    enable = mkBoolOpt false;
    dataHome = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      (makeDesktopItem {
        name = "feeluown";
        desktopName = "FeelUOwn";
        icon = "${configDir}/feeluown/feeluown.png";
        exec = "feeluown --log-to-file";
        categories = "AudioVideo;Audio;Player;Qt;";
        terminal = "false";
        startupNotify = "true";
      })] ++ (if cfg.dataHome then [
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
       '')
      ] else [ my.feeluown-full ]);
    home = if cfg.dataHome then {
      dataFile."feeluown/.fuorc".source = "${configDir}/feeluown/.fuorc";
    } else {
      file.".fuorc".source = "${configDir}/feeluown/.fuorc";
    };
  };
}
