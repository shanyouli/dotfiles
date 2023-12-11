{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.battery;
in {
  options.modules.macos.battery = {
    enable = mkBoolOpt false;
    maxPower = mkOpt (types.ints.between 0 100) 75;
    minPower = mkOpt (types.ints.between 0 100) 65;
  };

  config = mkIf cfg.enable {
    homebrew.casks = ["battery"]; # "aldente" # 电池管理
    launchd.user.agents.battery = {
      script = ''
        while true ; do
          lastBattery=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
          if $(pmset -g batt | grep 'AC' >/dev/null); then
             if [[ $lastBattery -ge ${toString cfg.maxPower} ]]; then
               battery maintain ${toString cfg.minPower}
               echo "Reduce the power to ${toString cfg.minPower}% ..."
               battery discharge ${toString (cfg.minPower)}
               battery charging off
             elif [[ $lastBattery -le ${toString cfg.minPower} ]]; then
               battery maintain ${toString cfg.maxPower}
               echo "Will charge to ${toString cfg.maxPower}% ..."
               battery charge ${toString (cfg.maxPower)}
               battery charging off
             else
               echo "current battery $lastBattery, sleep ..."
               sleep 60
             fi
          else
            echo "Not on charge, no regulation."
            sleep 300
            battery maintain stop
          fi
        done
      '';
      serviceConfig.RunAtLoad = true;
      serviceConfig.StandardOutPath = "${config.my.hm.dir}/Library/Logs/mybatter.log";
      serviceConfig.StandardErrorPath = "${config.my.hm.dir}/Library/Logs/mybatter.error.log";
      path = [config.environment.systemPath];
    };
  };
}
