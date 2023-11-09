{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.hardware.light;
in {
  options.modules.hardware.light = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # user.packages = [ pkgs.light ];
    environment.systemPackages = [ pkgs.light ];
    services.udev.packages = [ pkgs.light ];
    user.extraGroups = [ "video" ];
  };
}
