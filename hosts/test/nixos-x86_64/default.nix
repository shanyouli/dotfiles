{config, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];
  networking.hosts."::1" = [config.networking.hostName];
  networking.hosts."127.0.0.1" = [config.networking.hostName];
}
