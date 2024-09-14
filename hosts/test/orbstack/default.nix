{modulesPath, ...}: {
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
  environment.noXlibs = false;

  # modules config
  # modules = {
  #   shell.zinit.enable = true;
  #   shell.vivid.enable = true;
  #   shell.zoxide.enable = true;
  #   shell.wget.enable = true;
  #   tmux.enable = true;
  #   shell.rsync.enable = true;
  #   shell.direnv.enable = true;
  #   shell.git.enable = true;
  #   shell.nix-index.enable = true;
  #   editor.nvim.enable = true;
  # };
  modules = {
    # app.qbittorrent.enable = true;
    # app.qbittorrent.enGui = true;

    app.editor.default = "nvim";
    # app.editor.helix.enable = true;
    # app.editor.emacs.enable = true;
    # app.editor.vscode.enable = true;

    dev.manager.default = "mise";
    # dev.bash.enable = true;
    # dev.cc.enable = true;
    # dev.java.enable = true;
    # dev.java.versions = ["oracle-21.0.1" "liberica-8u392+9"];
    # dev.java.global = "oracle-21.0.1";
    # dev.lua.enable = true;
    # dev.nix.enable = true;
    # dev.rust.enable = true;
    # dev.python.enable = true;
    # dev.python.versions = ["3.12" "3.10" "3.11"];
    # dev.python.global = "3.11";
    # dev.python.manager = "rye";
    # dev.python.rye.manager = true;
    # dev.python.poetry.enable = true;
    # dev.node.enable = true;

    # gui.enable = true;
    # gui.localsend.enable = true;

    # gui.browser.default = "firefox";
    # gui.browser.chrome.enable = true;

    # gui.media.flameshot.enable = true;

    # gui.media.music.netease.enable = true;

    # gui.media.video.default = "mpv";
    # gui.media.video.vlc.enable = true;

    # gui.terminal.default = "kitty";
    # gui.terminal.wezterm.enable = true;
    # gui.terminal.alacritty.enable = true;

    rime.enable = true;

    shell.default = "zsh";

    shell.prompt.default = "oh-my-posh";
    shell.nix-your-shell.enable = true;
    shell.zsh.zinit.enable = true;

    shell.vivid.enable = true;
    shell.zoxide.enable = true;
    shell.atuin.enable = true;
    shell.nix-index.enable = true;
    shell.direnv.enable = true;

    # shell.nushell.enable = true;
    # shell.carapace.enable = true;

    archive.default = "ouch";

    # translate.enable = true;
    # translate.deeplx.enable = false;
    # translate.deeplx.service.startup = false;

    download.enable = true;
    download.aria2.aria2p = true;
    download.aria2.service.startup = false;

    # db.enable = true;
    # db.mysql.enable = true;
    # db.mysql.service.startup = false;

    media.enable = true;
    media.stream.enable = true;
    media.music.default = "mpd";
    media.music.netease.enable = true;
    media.music.mpd.service.startup = true;

    # nginx.enable = true;
    proxy.default = "sing-box";
    # proxy.sing-box.package = pkgs.unstable.sing-box;
    proxy.service.enable = true;

    alist.enable = true;
    alist.service.startup = false;

    rsync.enable = true;
    navi.enable = true;
    tmux.enable = true;
    tmux.service.startup = true;
    adb.enable = true;
    ugrep.enable = true;
    gpg.enable = true;
    gpg.cacheTTL = 360000;
    git.enable = true;
    git.enGui = false; # 使用网页管理 github
    gopass.enable = true;
    gopass.enGui = false;
    trash.enable = true;
    just.enable = true;

    shell.bash.enable = true; # 2024-09-11 添加 bash 配置
  };
}
