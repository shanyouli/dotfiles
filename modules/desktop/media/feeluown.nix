{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.media.feeluown;
    cfgFile = "${configDir}/feeluown/.fuorc";
in {
  options.modules.desktop.media.feeluown = {
    enable = mkBoolOpt false;
    dataHome = mkBoolOpt true;
    rcFile = mkOption {
      type = types.str;
      default = ".fuorc";
      description = "Don't modify it, feeluown configuration file.";
    };
    pkg = mkOption {
      type = types.package;
      default = pkgs.my.feeluown-full;
      description = "Don't modify it, Feeluown default package.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.dataHome {
      modules.desktop.media.feeluown = {
        # see @https://github.com/mjlbach/nix-dotfiles/blob/master/nixpkgs/configs/doom/shell.nix
        pkg = pkgs.symlinkJoin {
          name = "my-feeluown-${pkgs.my.feeluown-full.version}";
          paths = [ pkgs.my.feeluown-full ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            for i in $out/bin/* ; do
              wrapProgram $i \
                --set HOME "${xdgData}/feeluown"
            done
          '';
        };
        rcFile = ".local/share/feeluown/.fuorc";
      };
    })

    {
      user.packages = [ cfg.pkg pkgs.my.listen1 ];
      home.file."${cfg.rcFile}".source = "${cfgFile}";
    }
  ]);
}
