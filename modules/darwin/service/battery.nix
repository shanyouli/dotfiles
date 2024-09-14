{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.service.battery;
  batter-script = pkgs.writeScriptBin "battery-service" ''
    #!${pkgs.stdenv.shell}
    low=${toString cfg.minPower}
    high=${toString cfg.maxPower}

    function get_battery() {
        if [[ -f $HOME/.battery/maintain.percentage ]]; then
            cat $HOME/.battery/maintain.percentage
        fi
    }
    current_setting=$(get_battery)
    current_battery=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)

    function maintain() {
        if [[ -n $current_setting ]] && [[ "$current_setting" != "$1" ]]; then
            battery maintain $1
        fi
    }

    if [[ $current_battery -le $low ]]; then
        maintain $high
    elif [[ $current_battery -ge $high ]]; then
        maintain $low
    fi
  '';
in {
  options.modules.service.battery = {
    enable = mkBoolOpt false;
    maxPower = mkOpt (types.ints.between 0 100) 75;
    minPower = mkOpt (types.ints.between 0 100) 65;
  };

  config = mkIf cfg.enable {
    homebrew.casks = ["battery"]; # "aldente" # 电池管理
    launchd.user.agents.battery = {
      serviceConfig = {
        ProgramArguments = ["${batter-script}/bin/battery-service"];
        RunAtLoad = true;
        StandardErrorPath = "${config.user.home}/Library/Logs/mybatter.error.log";
        StartInterval = 600;
        # serviceConfig.StandardOutPath = "${config.user.home}/Library/Logs/mybatter.log";
        # serviceConfig.StartCalendarInterval = [{Minute = 10;}];
      };
      path = [config.modules.service.path];
    };
  };
}
