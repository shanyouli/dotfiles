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
        fcitx.enable = true;
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
        # firefox.extEnable = false;
        qutebrowser.enable = true;
      };
      # font.enable = true;
      media.graphics.enable = true;
      media.graphics.tools.enable = true;
      media.graphics.raster.enable = false;
      media.graphics.vector.enable = false;
      media.graphics.sprites.enable = false;
      media.video.enable = true;
      media.video.zyEn = true;
      media.music.enable = true;
      media.music.netease.enable = true;
      media.rime.enable = true;
      media.documents.enable = true;
      term = {
        default = "xst";
        xst.enable = true;
      };
     vm.virtualbox.enable = true;
    };
    editors = {
      default = "nvim";
      emacs.enable = true;
      # emacs.rimeEnable = false;
      # emacs.gccEnable   = false;
      # vim.enable = true;
      vscode.enable = true;
    };
    dev = {
      shell.enable = true;
      cc.enable = true;
      python.enable = true;
      go.enable  = true;
      rust.enable = true;
	  node.enable = true;
      nix.enable = true;
    };
    services = {
      xray.enable = true;
      xray.xtls.enable = false;
      xray.cloudIp = "104.16.209.216";
      clipmenu.enable = true;
      dropbox.enable = true;
      docker.enable = true;
      xkeysnail.enable = true;
    };
    shell = {
      mirrors.enable = true;
      pass.enable = true;
      adb.enable = true;
      aria2.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      tmux.enable = true;
      sdcv.enable = true;
      trash.enable = true;
    };
    theme.enable = true;
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
