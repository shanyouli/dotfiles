# see@https://git.orbekk.com/nixos-config.git/tree/config/thinkpad.nix
{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.hardware.thinkpad;
    cfgBat = pkgs.tpacpi-bat;
    cfgBatCmd = "${cfgBat}/bin/tpacpi-bat";
in {
  options.modules.hardware.thinkpad.enable = mkBoolOpt false;

  config = mkIf cfg.enable {
    services = {
      tlp = {
        enable = true;
        settings = {
          "SATA_LINKPWR_ON_BAT" = "max_performance";
          "TPACPI_ENABLE" = "1";
          "TPSMAPI_ENABLE" = "0"; # False: 0, TRUE: 1;
        };
      };
      # xserver.xkbModel = "thinkpad60";
    };

    boot = {
      # tm_smapi 不支持，改为tpacpi-bat
      kernelModules = [ "thinkpad_acpi" "fbcon" "i915" "acpi_call" ];
      extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    };
    environment.systemPackages = [ cfgBat ];
    rootRun = [ "${cfgBatCmd}" ];
    systemd.services = {
      battery_threshold = {
        description = "Set battery charging thresholds.";
        # path = [ pkgs.tpacpi-bat ];
        after = [ "basic.target" ];
        wantedBy = [ "multi-user.target" ];
        script =
          let cmd = "${config.security.wrapperDir}/sudo ${cfgBatCmd}";
          in ''
            # ${cmd} -s FD 1 1
            ${cmd} -v -s startThreshold 0 75
            ${cmd} -v -s stopThreshold 0 85
          '';
      };
    };
  };
}
