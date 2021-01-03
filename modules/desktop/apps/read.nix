{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.apps.read;
in {
  options.modules.desktop.apps.read = {
    enable = mkBoolOpt false;
    zathura = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      calibre
      (mkIf cfg.zathura zathura)
    ];
    home = (mkMerge [
      (mkIf cfg.zathura {
        configFile."zathura/zathurarc".source = "${configDir}/zathura/zathurarc";
        defaultApps."application/pdf" = "org.pwmt.zathura.desktop";
      })
    ]);
  };
}
