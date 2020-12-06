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
      default = "${cfgConf}";
    };
  };

  config = mkIf cfg.enable {
    hardware.uinput.enable = true;
    # user.extraGroups = [ "uinput" ];
    environment.systemPackages = [ cfgPkg ];
    rootRun = [ "${cfgPkg}/bin/xkeysnail" ];
    home = {
      configFile = (if cfg.conf == "${cfgConf}" then {
        "xkeysnail/config.py".source = "${configDir}/xkeysnail/config.py" ;
      } else {});
      services.xkeysnail = {
        Unit.Description = "Button exchange with xkeysnail";
        Install.WantedBy = [ "graphical-session.target" ];
        Service = let
          cmd = "${cfgPkg}/bin/xkeysnail";
          sudoCmd = "${config.security.wrapperDir}/sudo";
        in {
          # Environment = [ "DISPLAY=:0" ]; 如果无法启动，取消这行注释
          Type = "simple";
          KillMode = "process";
          ExecStart = "${sudoCmd} ${cmd} --quiet --watch ${cfg.conf}";
          Restart = "on-failure";
          RestartSec = "3";
        };
      };
    };
  };
}
