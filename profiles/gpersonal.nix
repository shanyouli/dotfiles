{ config, lib, pkgs, ... }: {
  user.name = "lyeli";
  hm = { imports = [ ./home-manager/personal.nix ./home-manager/darwin.nix ]; };
}
