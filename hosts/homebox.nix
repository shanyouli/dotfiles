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

    # tui 工具
    archive.default = "ouch";

    translate.enable = true;
    translate.deeplx.enable = false;
    translate.deeplx.service.startup = false;

    download.enable = true;
    download.aria2.enable = true;
    download.aria2.aria2p = true;
    download.aria2.service.startup = false;

    db.enable = true;
    db.mysql.enable = true;
    db.mysql.service.startup = false;

    media.enable = true;
    media.stream.enable = true;
    media.music.default = "mpd";
    media.music.netease.enable = true;
    media.music.mpd.service.startup = true;

    gui.media.music.netease.enable = false;

    gui.media.video.default = "mpv";

    # 比较后选择
    media.music.cmus.enable = true;
    media.music.musikcube.enable = true;
    media.music.mpd.default = "rmpc";
    media.music.mpd.ncmpcpp.enable = true;

    nginx.enable = true;
    nginx.workDir = "/opt/nginx";

    proxy.default = "sing-box";
    proxy.sing-box.package = pkgs.unstable.sing-box;
    proxy.service.enable = true;
    proxy.configFile = "${config.user.home}/Nutstore Files/我的坚果云/clash/singbox.json";

    alist.enable = true;
    alist.service.startup = false;

    # app
    app.qbittorrent.enGui = false;
    app.qbittorrent.service.startup = false;
    app.qbittorrent.service.enable = true;

    app.editor.emacs.enable = true;
    app.editor.emacs.service.enable = true;

    app.editor.default = "nvim";
    # app.editor.nvim.enable = true;
    app.editor.nvim.enGui = false; # GUI 编辑工具为emacs
    app.editor.vscode.enable = true;

    # gui
    gui.terminal.default = "kitty";

    gui.localsend.enable = true; # 需要gui，局域网文件传输工具

    gui.browser.default = "firefox";
    # browser.firefox.extensions = lib.mkForce [];
    gui.browser.fallback = "chrome";
    # browser.fallback = pkgs.unstable.darwinapps.vivaldi;
    gui.media.flameshot.enable = true;

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

    # media.music.enable = true;
    # media.music.netease.enGui = false;
    # media.video.enable = true;

    dev.bash.enable = true;

    dev.python.enable = true;
    dev.python.versions = ["3.12" "3.10" "3.11"];
    dev.python.global = "3.11";
    dev.python.manager = "rye";
    dev.python.rye.manager = true;
    dev.python.poetry.enable = true;

    dev.nix.enable = true;
    dev.java.enable = true;
    dev.java.versions = ["oracle-21.0.1" "liberica-8u392+9"];
    dev.java.global = "oracle-21.0.1";
    dev.lua.enable = true;
    dev.cc.enable = true;
    dev.node.enable = true;
    dev.toml.fmt = true;
    dev.enWebReport = true;
    dev.rust.enable = true;

    # macos
    macos.enable = true;
    macos.docker.enable = true;
    macos.app.enable = true;
    macos.arc.enable = true;
    macos.karabiner.enable = true;
    macos.safari.enable = true;
    macos.stopAutoReopen = true;
    macos.music.lx.enable = true;

    macos.games.enable = true;
    macos.hammerspoon.enable = true;
    macos.rime.enable = true;
    macos.brew.mirror = "tuna";
    macos.duti.enable = true;
    macos.netdriver.enable = true;

    service.battery.enable = false;
    service.yabai.enable = true;
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
