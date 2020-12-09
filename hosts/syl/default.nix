# Syl -- My desktop
{ lib, pkgs, ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
  ];
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
        read.enable = true;
      };
      bspwm.enable = true;
      browsers = {
        default = "firefox";
        firefox.enable = true;
        # firefox.extEnable = false;
        qutebrowser.enable = true;
      };
      media.mpv.enable = true;
      term = {
        default = "xst";
        st.enable = true;
      };
     vm.virtualbox.enable = true;
    };
    editors = {
      default = "nvim";
      emacs.enable = true;
      # emacs.gccEnable   = false;
      vim.enable = true;
    };
    dev = {
      cc.enable = true;
    };
    proxy = {
      default = "v2ray";
      clash.enable = true;
      v2ray.enable = true;
      # v2ray.asset = false;
      # v2ray.vless = false;
    };
    services = {
      dropbox.enable = true;
      docker.enable = true;
      xkeysnail.enable = true;

    };
    shell = {
      adb.enable = true;
      aria2.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      htop.enable = true;
      sdcv.enable = true;
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
      thinkpad.enable = true;
    };
  };
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Shanghai";
  networking.useDHCP = false;
  # see @https://nixos.wiki/wiki/NTP
  networking.timeServers = lib.mkBefore [ "ntp.aliyun.com" ];
 }
