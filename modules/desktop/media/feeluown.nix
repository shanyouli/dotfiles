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
        pkg = pkgs.my.feeluown-full.overrideAttrs(attrs: {
          postInstall = (attrs.postInstall or "") + ''
            for i in $out/bin/* ; do
              wrapProgram $i \
                --set HOME "${xdgData}/feeluown"
            done
          '';
        });
        rcFile = ".local/share/feeluown/.fuorc";
      };
    })

    {
      user.packages = [ cfg.pkg ];
      home.file."${cfg.rcFile}".source = "${cfgFile}";
    }
  ]);
}
