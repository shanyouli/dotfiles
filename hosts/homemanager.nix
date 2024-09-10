{...}: {
  modules = {
    shell.default = "zsh";
    shell.nushell.enable = true;
    shell.atuin.enable = true;
    shell.vivid.enable = true;
    shell.prompt.default = "oh-my-posh";
    shell.prompt.zsh.enable = false;
    shell.prompt.starship.enable = true;
    shell.nix-index.enable = true;
    shell.nix-your-shell.enable = true;
    shell.direnv.enable = true;
    shell.zoxide.enable = true;

    modern.enable = true;
    fastfetch.enable = true;
    adb.enable = true;
    git.enable = true;
    just.enable = true;
    gpg.enable = true;
    ugrep.enable = true;
    tmux.enable = true;
    gopass.enable = true;
    navi.enable = true;
    trash.enable = true;

    python.pipx.enable = true;
    alist.enable = true;

    archive.default = "ouch";
    db.enable = true;
    db.mysql.enable = true;

    download.enable = true;

    media.enable = true;

    media.music.default = "mpd";
    media.music.cmus.enable = true;
    media.music.musikcube.enable = true;
    media.music.mpd.default = "ncmpcpp";

    translate.enable = true;
    gui.enable = true;
  };
}
