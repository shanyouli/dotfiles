{
  config,
  lib,
  my,
  pkgs,
  ...
}:
with lib;
with my;
{
  # imports = [inputs.home-manager.nixosModules.home-manager];
  boot = {
    kernelPackages = mkDefault pkgs.linuxKernel.packages.linux_6_1;
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = mkDefault true;
    };
  };
  # environment.systemPackages = with pkgs; [cached-nix-shell];

  # Change me later!
  user.initialPassword = "nixos";
  users.users.root.initialPassword = "nixos";

  #  xdg
  environment.sessionVariables = config.modules.xdg.value;
  environment.extraInit = ''
    export XAUTHORITY=/tmp/Xauthority
    [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
  '';
}
