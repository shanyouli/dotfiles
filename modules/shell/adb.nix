{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.shell.adb;
in {
  options.modules.shell.adb = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.adb.enable = true;
    services.udev.packages = [ pkgs.android-udev-rules ];
    user.extraGroups = [ "adbusers" ];
  };
}
