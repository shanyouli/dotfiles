# see@https://git.orbekk.com/nixos-config.git/tree/config/thinkpad.nix
{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.hardware.thinkpad;
in {
  options.modules.hardware.thinkpad.enable = mkBoolOpt false;

  config = mkIf cfg.enable {
    services = {
      tlp = {
        enable = true;
        settings = {
          "SATA_LINKPWR_ON_BAT" = "max_performance";
        };
      };
      xserver.xkbModel = "thinkpad60";
    };

    boot = {
      kernelModules = [ "tp_smapi" "thinkpad_acpi" "fbcon" "i915" "acpi_call" ];
      extraModulePackages = with config.boot.kernelPackages; [ tp_smapi acpi_call ];
    };

    systemd.services = {
      battery_threshold = {
        description = "Set battery charging thresholds.";
        path = [ pkgs.tpacpi-bat ];
        after = [ "basic.target" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
        tpacpi-bat -s ST 1 60
        tpacpi-bat -s ST 2 60
        tpacpi-bat -s SP 1 80
        tpacpi-bat -s SP 2 80
      '';
      };
    };
  };
}
