{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
    ./lxd.nix
    ./orbstack.nix
  ];
  boot.loader.systemd-boot.enable = false;
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "21.05"; # Did you read the comment?

  # As this is intended as a stadalone image, undo some of the minimal profile stuff
  # documentation.enable = true;
  documentation.nixos.enable = true;
  # environment.noXlibs = false;

  # modules config
  modules = {
    app = {
      qbittorrent = {
        enable = true;
        enGui = false;
      };
      editor = {
        default = "nvim";
        # helix.enable = true;
        # emacs.enable = true;
        # vscode.enable = true;
      };
    };
    dev = {
      manager.default = "mise";
      # bash.enable = true;
      # cc.enable = true;
      # java = {
      #   enable = true;
      #   versions = ["oracle-21.0.1" "liberica-8u392+9"];
      #   global = "oracle-21.0.1";
      # };
      # lua.enable = true;
      # nix.enable = true;
      # rust.enable = true;
      # python = {
      #   enable = true;
      #   versions = ["3.12" "3.10" "3.11"];
      #   global = "3.11";
      #   manager = "rye";
      #   rye.manager = true;
      #   poetry.enable = true;
      # };
      # node.enable = true;
    };

    # gui = {
    #   enable = true;
    #   localsend.enable = true;

    #   browser = {
    #     default = "firefox";
    #     chrome.enable = true;
    #   };
    #   media = {
    #     flameshot.enable = true;

    #     music.netease.enable = true;
    #     video = {
    #       default = "mpv";
    #       vlc.enable = true;
    #     };
    #   };
    #   terminal = {
    #     default = "kitty";
    #     wezterm.enable = true;
    #     alacritty.enable = true;
    #   };
    # };

    # rime.enable = true;

    shell = {
      default = "zsh";
      # bash.enable = true; # 2024-09-11 添加 bash 配置

      prompt.default = "oh-my-posh";
      nix-your-shell.enable = true;
      zsh.zinit.enable = true;

      vivid.enable = true;
      zoxide.enable = true;
      atuin.enable = true;
      nix-index.enable = true;
      # direnv.enable = true;

      # nushell.enable = true;
      # carapace.enable = true;
    };

    archive.default = "ouch";
    # translate = {
    #   enable = true;
    #   deeplx = {
    #     enable = false;
    #     service.startup = false;
    #   };
    # };
    # download = {
    #   enable = true;
    #   aria2 = {
    #             aria2p = !pkgs.stdenvNoCC.hostPlatform.isDarwin;
    #     service.startup = false;
    #   };
    # };
    # db = {
    #   enable = true;
    #   mysql = {
    #     enable = true;
    #     service.startup = false;
    #   };
    # };
    # media = {
    #   enable = true;
    #   stream.enable = true;
    #   music = {
    #     default = "mpd";
    #     netease.enable = true;
    #     mpd.service.startup = true;
    #   };
    # };

    # nginx.enable = true;
    proxy = {
      default = "sing-box";
      # proxy.sing-box.package = pkgs.unstable.sing-box;
      service.enable = true;
    };

    alist = {
      enable = false;
      service.startup = false;
    };
    rsync.enable = true;
    # navi.enable = true;
    tmux = {
      enable = true;
      service.startup = true;
    };
    # adb.enable = true;
    # ugrep.enable = true;
    gpg = {
      enable = true;
      cacheTTL = 360000;
    };
    git = {
      enable = true;
      enGui = false; # 使用网页管理 github
    };
    gopass = {
      enable = true;
      enGui = false;
    };
    trash.enable = true;
    just.enable = true;
  };
}
