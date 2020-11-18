# Syl -- My desktop
{ ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix ];
  nix.binaryCaches = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];
  networking.proxy.default = "http://127.0.0.1:7890";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
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
    services = {
      clash.enable = true;
      docker.enable = true;
    };
    shell = {
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
  environment.extraInit = ''
    unset https_proxy http_proxy all_proxy rsync_proxy ftp_proxy
  '';
  networking.useDHCP = false;
 }
