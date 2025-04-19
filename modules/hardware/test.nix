{ lib, pkgs, ... }:
{
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_6_1;
    loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = lib.mkDefault true;
    };
  };
}
