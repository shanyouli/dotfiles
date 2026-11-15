{ pkgs, ... }: {
  modules = {
    files.yazi.enable = true;
    dev.lix.enable = true;
    shell.m.enable = true;
    network.qbittorrent = {
      enable = true;
      enGui = true;
    };
    editor = {
      default = "nvim";
      nvim = {
        treesit = "all";
      };
      helix.enable = true;
      emacs.enable = true;
      vscode.enable = true;
      zed.enable = true;
    };
    network.tg.enable = true;
    dev = {
      scheme.enable = true;
      go.enable = true;
      bash.enable = true;
      cc.enable = true;
      java = {
        enable = true;
        versions = [
          "oracle-21.0.1"
          "liberica-8u392+9"
        ];
        global = "oracle-21.0.1";
      };
      lua.enable = true;
      nix.enable = true;
      rust.enable = true;
      python = {
        enable = true;
        versions = [
          "3.14"
          "3.13"
          "3.12"
        ];
        global = "3.12";
        venv = "uv";
        poetry.enable = true;
      };
      ai.enable = true;
      fmt = {
        toml.enable = true;
      };
      js.enable = true;
      zig.enable = true;
    };

    fonts.enable = true;
    network.localsend.enable = true;

    network.browser = {
      default = "firefox";
      chrome.enable = pkgs.stdenv.hostPlatform.isDarwin || pkgs.stdenv.hostPlatform.isx86_64;
    };
    media = {
      flameshot.enable = true;

      music.gtk.netease.enable = true;
      video = {
        default = "mpv";
        vlc.enable = true;
      };
    };
    shell.terminal = {
      default = "kitty";
      ghostty.enable = true;
      wezterm.enable = true;
      alacritty.enable = true;
    };

    tools.rime.enable = true;

    shell = {
      default = "zsh";
      bash.enable = true; # 2024-09-11 添加 bash 配置
      fish.enable = true;
      prompt.default = "oh-my-posh";
      nix-your-shell.enable = true;
      zsh.zinit.enable = true;

      vivid.enable = true;
      zoxide.enable = true;
      atuin.enable = true;
      nix-index.enable = true;
      direnv.enable = true;

      nushell.enable = true;
      carapace.enable = true;
    };

    files.archive.default = "ouch";
    tools.translate = {
      enable = true;
      deeplx = {
        enable = false;
        service.startup = false;
      };
    };
    services.download.aria2 = {
      aria2p = !pkgs.stdenvNoCC.hostPlatform.isDarwin;
      service.startup = false;
    };
    tools.db = {
      enable = true;
    };
    services.db.mysql = {
      enable = true;
      service.startup = false;
    };
    media = {
      enable = true;
      stream.enable = true;
      music = {
        default = "mpd";
        netease.enable = true;
        kew.enable = true;
      };
    };
    services.media.mpd.service.startup = true;

    dev.nh.enable = true; # nh 不支持 --impure
    services.nginx = {
      enable = true;
      www.enable = true;
    };
    services.proxy = {
      default = "sing-box";
      # services.proxy.sing-box.package = pkgs.sing-box;
      service.enable = true;
    };

    services.files.alist = {
      enable = false;
      service.startup = false;
    };
    files.rsync.enable = true;
    tools.navi.enable = true;
    shell.tmux = {
      enable = true;
      service.startup = true;
    };
    tools.adb.enable = true;
    tools.ugrep.enable = true;
    security.gpg = {
      enable = true;
      cacheTTL = 360000;
    };
    dev.git = {
      enable = true;
      enGui = false; # 使用网页管理 github
    };
    dev.jujutsu.enable = true;
    security.gopass = {
      enable = true;
      enGui = false;
    };
    files.trash.enable = true;
    dev.just.enable = true;
  };
}
