{ config, lib, pkgs, options, ... }:
with lib;
with lib.my;
let cfg = config.modules.services.clipmenu;
in {
  options.modules.services.clipmenu = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [ clipmenu xdotool  ];
    env.CM_DIR = "$XDG_CACHE_HOME/clipmenu";
    home.services.clipmenu = {
      Unit.Description = "Clip Service";
      Unit.After = [ "graphical-session.target" ];
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        Environment = [
          "CM_DIR=${xdgCache}/clipmenu"
          "CM_IGNORE_WINDOW=QtPass"
          "PATH=${pkgs.coreutils}/bin:${pkgs.xdotool}/bin"
        ];
        ExecStart = "${pkgs.clipmenu}/bin/clipmenud";
      };
    };
  };
}
