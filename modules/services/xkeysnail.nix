{ config, lib, pkgs, options, ... }:
with lib;
with lib.my;
let cfg = config.modules.services.xkeysnail;
    cfgConf = "${xdgConfig}/xkeysnail/config.py";
    cfgPkg = pkgs.my.xkeysnail;
in {
  options.modules.services.xkeysnail = {
    enable = mkBoolOpt false;
    conf = mkOption {
      type = types.str;
      default = "/etc/xkeysnail/config.py";
    };
    xkeysnailUserName = mkOption {
      type = types.str;
      default = "xkeysnail";
      description = ''
        The user who would run the xkeysnail systemd service,
        will be created automatically.
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.uinput.enable = true;
    # user.extraGroups = [ "uinput" ];
    environment.systemPackages = with pkgs; [
      cfgPkg
      xorg.xhost
      procps
    ];

    environment.etc.xkeysnail.source = "${configDir}/xkeysnail";

    systemd.services.xkeysnail = let
      sudoCmd = "${config.security.wrapperDir}/sudo";
    in {
      wantedBy = [ "graphical.target" ];
      description = "xkeysnail Key management tool.";
      environment = { DISPLAY = ":0"; };
      script = ''
        exec ${sudoCmd} ${cfgPkg}/bin/xkeysnail --quiet --watch ${cfg.conf}
      '';
      unitConfig = { ConditionPathExists = cfg.conf; };
      preStop = "${sudoCmd} ${pkgs.procps}/bin/pkill -9 xkeysnail";
      serviceConfig = {
        Restart = "always";
        Type = "simple";
        RestartSec = "10";
      };
    };

    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:root >/dev/null
    '';
  };
}
