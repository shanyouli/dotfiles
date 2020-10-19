# Syl -- My desktop
{ pkgs, options, config, ... }:

{
  imports = [
    ../personal.nix # common settings
    ./hardware-configuration.nix
  ];
  nix.binaryCaches = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  networking.proxy.default = "http://127.0.0.1:7890";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  modules = {
    desktop = {
      bspwm.enable = true;
      apps.rofi.enable = true;
      apps.fcitx.enable = true;
      apps.vm.enable = true;
      term.default = "xst";
      term.st.enable = true;

      browsers.default = "firefox";
      browsers.firefox.enable = true;
    };
    dev = {
      lua.enable = true;
    };
    editors = {
      default = "nvim";
      vim.enable = true;
      emacs.enable = true;
    };
    services = {
      clash.enable = true;
      dropbox.enable = true;
    };
    shell = {
      direnv.enable = true;
      git.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      gnupg.enable = true;
    };
    themes.fluorescence.enable = true;
  };
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Shanghai";
  environment.extraInit = ''
    unset https_proxy http_proxy all_proxy rsync_proxy ftp_proxy
  '';
 }
