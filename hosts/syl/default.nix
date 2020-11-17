# Syl -- My desktop
{ pkgs, options, config, ... }:

{
  imports = [
    ../personal.nix # common settings
    ./hardware-configuration.nix
  ];
  nix.binaryCaches = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  modules = {
    desktop = {
      font.enable = true;
      bspwm.enable = true;
      apps.rofi.enable = true;
      apps.fcitx.enable = true;
      apps.vm.enable = true;
      term.default = "xst";
      term.st.enable = true;

      browsers.default = "firefox";
      browsers.firefox.enable = true;
      browsers.qutebrowser.enable = true;
    };
    dev = {
      lua.enable = true;
      ruby.enable = true;
      adb.enable = true;
    };
    editors = {
      default = "nvim";
      vim.enable = true;
      emacs.enable = true;
    };
    proxy = {
      default = "clash";
      clash.enable = true;
    };
    services = {
      dropbox.enable = true;
    };
    shell = {
      aria2.enable = true;
      direnv.enable = true;
      git.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      gnupg.enable = true;
      trash.enable = true;
    };
    themes.fluorescence.enable = true;
  };
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Shanghai";
 }
