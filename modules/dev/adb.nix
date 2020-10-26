{ config, lib, options, pkgs, ... }:
with lib;

let cfg = config.modules.dev.adb;
in {

  options.modules.dev.adb = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf cfg.enable {
    programs.adb.enable = true;
    services.udev.packages = [
      pkgs.android-udev-rules
    ];
    my.user.extraGroups = [ "adbusers" ];
  };
}
