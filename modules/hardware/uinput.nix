{ config, lib, options, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.hardware.uinput;
in {
  options.modules.hardware.uinput = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    hardware.uinput.enable  = true;
    user.extraGroups = [ "uinput" ];
  };
}
