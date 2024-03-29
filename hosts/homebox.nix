{
  config,
  pkgs,
  ...
}: {
  # user.name = "lyeli";
  nix = {
    gc = {user = config.user.name;};
    # Auto upgrade nix package and the daemon service.
    # services.nix-daemon.enable = true;
    # nix.package = pkgs.nix;
    # maxJobs = 4;
    settings.cores = 4;
  };
  modules = {
    # shared
    shell.zinit.enable = true;
    shell.vivid.enable = true;
    shell.zoxide.enable = true;
    shell.atuin.enable = true;
    shell.navi.enable = true;
    shell.wget.enable = true;
    shell.tmux.enable = true;
    shell.adb.enable = true;
    shell.rsync.enable = true;
    shell.starship.enable = false;
    shell.ugrep.enable = true;
    shell.gpg.enable = true;
    shell.gpg.cacheTTL = 36000;
    shell.direnv.enable = true;
    shell.git.enable = true;
    shell.git.enGui = false; # 使用网页管理 github
    shell.gopass.enable = true;
    shell.gopass.enGui = false;
    shell.nix-index.enable = true;
    shell.trash.enable = true;

    editor.nvim.enable = true;
    editor.nvim.enGui = false; # GUI 编辑工具为emacs
    editor.vscode.enable = true;
    editor.emacs.enable = true;
    editor.emacs.service.enable = true;

    media.music.enable = true;
    media.flameshot.enable = true;
    media.video.enable = true;

    dev.bash.enable = true;
    dev.python.enable = true;
    dev.python.plugins = ["3.12.1" "3.10.13" "3.11.7"];
    dev.nix.enable = true;
    dev.java.enable = true;
    dev.java.plugins = ["oracle-21.0.1" "liberica-8u392+9"];
    dev.lua.enable = true;
    dev.cc.enable = true;
    dev.node.enable = true;
    dev.toml.fmt = true;
    dev.enWebReport = true;
    dev.rust.enable = true;

    tool.sdcv.enable = true;
    browser.default = "firefox";
    # browser.firefox.extensions = lib.mkForce [];
    browser.fallback = pkgs.vivaldi-app;
    browser.chrome.enable = true;
    browser.chrome.package = pkgs.chromium-app;
    # theme.enable = true;

    # # macos
    macos.enable = true;
    macos.docker.enable = true;
    macos.app.enable = true;
    macos.karabiner.enable = true;
    macos.stopAutoReopen = true;
    service.clash.enable = true;
    service.clash.package = pkgs.mihomo;
    tool.clash.enSingbox = true;
    service.clash.configFile = "${config.user.home}/Nutstore Files/我的坚果云/clash/meta.yaml";

    macos.games.enable = true;
    macos.hammerspoon.enable = true;
    macos.rime.enable = true;
    macos.brew.mirror = "tuna";
    macos.duti.enable = true;

    service.nginx.enable = true;
    service.mysql.enable = true;
    service.deeplx.enable = true;
    service.alist.enable = true;
    service.battery.enable = false;
    service.yabai.enable = true;
    service.aria2.enable = true;
    service.qbittorrent.enable = true;
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
