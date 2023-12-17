{
  config,
  pkgs,
  ...
}: {
  # user.name = "lyeli";
  nix = {
    gc = {user = config.my.username;};
    # Auto upgrade nix package and the daemon service.
    # services.nix-daemon.enable = true;
    # nix.package = pkgs.nix;
    # maxJobs = 4;
    settings.cores = 4;
  };

  my = {
    terminal = "kitty";
  };
  modules = {
    # shared
    shell.enZinit = true;
    shell.enVivid = true;
    shell.enZoxide = true;
    shell.wget.enable = true;
    shell.tmux.enable = true;
    shell.adb.enable = true;
    shell.fzf.enable = true;
    shell.rsync.enable = true;
    shell.starship.enable = false;
    shell.ugrep.enable = true;
    shell.gpg.enable = true;
    shell.gpg.cacheTTL = 36000;
    shell.direnv.enable = true;
    shell.git.enable = true;
    shell.gopass.enable = true;
    shell.nix-init.enable = true;

    editor.nvim.enable = true;
    editor.nvim.enGui = false; # GUI 编辑工具为emacs
    editor.vscode.enable = true;

    media.netease-music.enable = true;
    media.download.enable = true;
    dev.enable = true;
    # asdf.enable = true;
    node.enable = true;
    rust.enable = true;
    rust.rustup = {
      enable = true;
      # version = "1.56.1";
      rlspEn = false;
    };
    sdcv.enable = true;
    # aria2.enable = true;
    firefox.enable = true;
    lua.enable = true;
    theme.enable = true;
    java.enable = true;

    # macos
    macos.enable = true;
    macos.app.enable = true;
    macos.karabiner.enable = true;
    macos.stopAutoReopen = true;
    macos.service.clash.enable = true;
    macos.service.clash.configFile = "${config.my.hm.dir}/Nutstore Files/我的坚果云/clash/meta.yaml";
    macos.music.enable = true;
    macos.games.enable = true;
    macos.yabai.enable = true;
    macos.emacs.enable = true;
    macos.emacs.serverEnable = true;
    macos.aria2.enable = true;
    macos.hammerspoon.enable = true;
    macos.alist.enable = true;
    macos.rime.enable = true;
    macos.iina.enable = true;
    macos.battery.enable = true;
    macos.asdf.enable = true;
    asdf.withDirenv = true;
    firefox.package = pkgs.firefox-esr-bin;
    macos.brew.mirror = "tuna";
    macos.nginx.enable = true;
    macos.service.mysql.enable = true;
    macos.service.deeplx.enable = true;
    # macos.mosdns.enable                  = true;
    # mail                                 = { enable = true; };
    # aerc                                 = { enable = true; };
    # irc.enable                           = true;
    # rescript.enable                      = false;
    # clojure.enable                       = true;
    # discord.enable                       = true;
    # hledger.enable                       = true;
  };
  # 如果你想使用macos别名请查看
  # https://github.com/LnL7/nix-darwin/issues/139#issuecomment-1230728610
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config =$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig                 = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild chang/nix/store/6xnavkbxd3kkkyssqds9p9rw9r47cj1q-gnupg-2.4.1/bin/gpg-connect-agentelog
  system.stateVersion = 4;
}
