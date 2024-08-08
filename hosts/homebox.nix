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
  user.uid = 501; # uid macos 创建的用户 默认 uid 为 501
  modules = {
    # shared
    shell.prompt.default = "oh-my-posh";
    shell.nix-your-shell.enable = true;
    shell.zinit.enable = true;
    shell.vivid.enable = true;
    shell.zoxide.enable = true;
    shell.atuin.enable = true;
    shell.navi.enable = true;
    shell.wget.enable = true;
    shell.tmux.enable = true;
    shell.adb.enable = true;
    shell.rsync.enable = true;
    shell.ugrep.enable = true;
    shell.gpg.enable = true;
    shell.gpg.cacheTTL = 360000;
    shell.direnv.enable = true;
    shell.git.enable = true;
    shell.git.enGui = false; # 使用网页管理 github
    shell.gopass.enable = true;
    shell.gopass.enGui = false;
    shell.nix-index.enable = true;
    shell.trash.enable = true;
    shell.just.enable = true;
    # shell.elvish.enable = true;
    shell.nushell.enable = true;
    shell.carapace.enable = true;

    shell.modern.enable = true;

    # terminal.alacritty.enable = true;
    terminal.default = "kitty";
    editor.default = "nvim";
    # editor.nvim.enable = true;
    editor.nvim.enGui = false; # GUI 编辑工具为emacs
    editor.vscode.enable = true;

    media.music.enable = true;
    media.music.netease.enGui = false;
    media.flameshot.enable = true;
    media.video.enable = true;

    dev.bash.enable = true;
    dev.python.enable = true;
    dev.python.versions = ["3.12" "3.10" "3.11"];
    dev.nix.enable = true;
    dev.java.enable = true;
    dev.java.versions = ["oracle-21.0.1" "liberica-8u392+9"];
    dev.lua.enable = true;
    dev.cc.enable = true;
    dev.node.enable = true;
    dev.toml.fmt = true;
    dev.enWebReport = true;
    dev.rust.enable = true;

    tool.sdcv.enable = true;
    tool.localsend.enable = true; # 需要gui，局域网文件传输工具
    browser.default = "firefox";
    # browser.firefox.extensions = lib.mkForce [];
    browser.fallback = "chrome";
    # browser.fallback = pkgs.unstable.darwinapps.vivaldi;

    # macos
    macos.enable = true;
    macos.docker.enable = true;
    macos.app.enable = true;
    macos.arc.enable = true;
    macos.karabiner.enable = true;
    macos.safari.enable = true;
    macos.stopAutoReopen = true;
    macos.music.lx.enable = true;

    tool.proxy.default = "sing-box";
    tool.proxy.sing-box.package = pkgs.unstable.sing-box;
    # tool.clash.enSingbox = true;
    tool.proxy.configFile = "${config.user.home}/Nutstore Files/我的坚果云/clash/singbox.json";

    macos.games.enable = true;
    macos.hammerspoon.enable = true;
    macos.rime.enable = true;
    macos.brew.mirror = "tuna";
    macos.duti.enable = true;
    macos.netdriver.enable = true;

    service.nginx.enable = true;
    service.mysql.enable = true;
    service.deeplx.enable = true;
    service.alist.enable = true;
    service.battery.enable = false;
    service.yabai.enable = true;
    service.aria2.enable = true;
    service.qbittorrent.enable = true;

    editor.emacs.enable = true;
    editor.emacs.service.enable = true;
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
