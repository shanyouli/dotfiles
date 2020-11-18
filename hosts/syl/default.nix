# Syl -- My desktop
{ ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix ];
  modules = {
    desktop = {
      apps = {
        fcitx = {
          enable = true;
          rime.enable = true;
        };
        keepassxc.enable = true;
        rofi.enable = true;
        thunar = {
          enable = true;
          gvfs.enable = true;
        };
      };
      bspwm.enable = true;
      browsers = {
        default = "firefox";
        firefox.enable = true;
      };
      media.mpv.enable = true;
      term = {
        default = "xst";
        st.enable = true;
      };
     vm.virtualbox.enable = true;
    };
    editors = {
      default = "emacs -nw";
      emacs.enable = true;
      vim.enable = true;
    };
    dev = {
      cc.enable = true;
    };
    proxy = {
      default = "clash";
      clash.enable = true;
    };
    services = {
      dropbox.enable = true;
      docker.enable = true;
    };
    shell = {
      aria2.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      htop.enable = true;
      trash.enable = true;
    };
    theme.active = "alucard";
    hardware = {
      sensors.enable = true;
      audio.enable = true;
      fs.enable = true;
      fs.ssd.enable = true;
      bluetooth.enable = true;
      bluetooth.audio.enable = true;
      light.enable = true;
    };
  };
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Shanghai";
  networking.useDHCP = false;
 }
