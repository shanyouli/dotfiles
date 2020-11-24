{ config, lib, pkgs, options, ... }:
with lib;
with lib.my;
let cfg = config.modules.services.xkeysnail;
in {
  options.modules.services.xkeysnail = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    hardware.uinput.enable = true;
    user.extraGroups = [ "uinput" ];
    environment.systemPackages = [ pkgs.my.xkeysnail ];

  };
}
