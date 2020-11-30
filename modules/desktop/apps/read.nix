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
    home.configFile = (if cfg.zathura then {
      "zathura/zathurarc".source = "${configDir}/zathura/zathurarc";
    } else {});
  };
}
