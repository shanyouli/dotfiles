{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; {
  imports = [inputs.home-manager.nixosModules.home-manager];
  boot = {
    kernelPackages = mkDefault pkgs.linuxKernel.packages.linux_6_1;
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = mkDefault true;
    };
  };
  environment.systemPackages = with pkgs.stable; [cached-nix-shell];

  # Change me later!
  user.initialPassword = "nixos";
  users.users.root.initialPassword = "nixos";

  #  xdg
  modules.xdg.enable = true;
  environment.sessionVariables = config.modules.xdg.value;
  environment.extraInit = ''
    export XAUTHORITY=/tmp/Xauthority
    [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
  '';
}
