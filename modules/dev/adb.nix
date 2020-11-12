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
    my = {
      env.ANDROID_SDK_HOME      = "$XDG_CONFIG_HOME/android" ;
      env.ANDROID_AVD_HOME      = "$XDG_DATA_HOME/android/" ;
      env.ANDROID_EMULATOR_HOME = "$XDG_DATA_HOME/android/" ;
      env.ADB_VENDOR_KEYS        = "$XDG_CONFIG_HOME/android" ;
      user.extraGroups          = [ "adbusers" ];
    };
  };
}
