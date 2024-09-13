{...}: {
  modules = {
    app.qbittorrent.enable = true;
    app.qbittorrent.enGui = true;

    app.editor.default = "nvim";
    app.editor.helix.enable = true;
    app.editor.emacs.enable = true;
    app.editor.vscode.enable = true;

    dev.manager.default = "mise";
    dev.bash.enable = true;
    dev.cc.enable = true;
    dev.java.enable = true;
    dev.java.versions = ["oracle-21.0.1" "liberica-8u392+9"];
    dev.java.global = "oracle-21.0.1";
    dev.lua.enable = true;
    dev.nix.enable = true;
    dev.rust.enable = true;
    dev.python.enable = true;
    dev.python.versions = ["3.12" "3.10" "3.11"];
    dev.python.global = "3.11";
    dev.python.manager = "rye";
    dev.python.rye.manager = true;
    dev.python.poetry.enable = true;
    dev.node.enable = true;

    gui.enable = true;
    gui.localsend.enable = true;

    gui.browser.default = "firefox";
    gui.browser.chrome.enable = true;

    gui.media.flameshot.enable = true;

    gui.media.music.netease.enable = true;

    gui.media.video.default = "mpv";
    gui.media.video.vlc.enable = true;

    gui.terminal.default = "kitty";
    gui.terminal.wezterm.enable = true;
    gui.terminal.alacritty.enable = true;

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

    shell.nushell.enable = true;
    shell.carapace.enable = true;

    archive.default = "ouch";

    translate.enable = true;
    translate.deeplx.enable = false;
    translate.deeplx.service.startup = false;

    download.enable = true;
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

    nginx.enable = true;
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
