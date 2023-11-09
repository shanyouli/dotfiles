{ config, lib, pkgs, ... }: {

  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail = "shanyouli6@gmail.com";
    userName = "Shanyou Li";
  };
}
