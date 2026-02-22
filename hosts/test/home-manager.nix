{ pkgs, ... }:
{
  modules = {
    tui = {
      yazi.enable = true;
      lix.enable = true;
    };
    app = {
      qbittorrent = {
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
      tg.enable = true;
    };
    dev = {
      scheme.enable = true;
      go.enable = true;
      manager.default = "mise";
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
          "3.12"
          "3.10"
          "3.11"
        ];
        global = "3.11";
        venv = "rye";
        poetry.enable = true;
        uv.enable = true;
      };
      ai.enable = true;
      js = {
        node.enable = true;
        bun.enable = true;
      };
      zig.enable = true;
    };

    gui = {
      enable = true;
      localsend.enable = true;

      browser = {
        default = "firefox";
        chrome.enable = pkgs.stdenv.hostPlatform.isDarwin || pkgs.stdenv.hostPlatform.isx86_64;
      };
      media = {
        flameshot.enable = true;

        music.netease.enable = true;
        video = {
          default = "mpv";
          vlc.enable = true;
        };
      };
      terminal = {
        default = "kitty";
        ghostty.enable = true;
        wezterm.enable = true;
        alacritty.enable = true;
      };
    };

    rime.enable = true;

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

    archive.default = "ouch";
    translate = {
      enable = true;
      deeplx = {
        enable = false;
        service.startup = false;
      };
    };
    download = {
      enable = true;
      aria2 = {
        aria2p = !pkgs.stdenvNoCC.hostPlatform.isDarwin;
        service.startup = false;
      };
    };
    db = {
      enable = true;
      mysql = {
        enable = true;
        service.startup = false;
      };
    };
    media = {
      enable = true;
      stream.enable = true;
      music = {
        default = "mpd";
        netease.enable = true;
        mpd.service.startup = true;
        kew.enable = true;
      };
    };

    nh.enable = true; # nh 不支持 --impure
    nginx = {
      enable = true;
      www.enable = true;
    };
    proxy = {
      default = "sing-box";
      # proxy.sing-box.package = pkgs.sing-box;
      service.enable = true;
    };

    alist = {
      enable = false;
      service.startup = false;
    };
    rsync.enable = true;
    navi.enable = true;
    tmux = {
      enable = true;
      service.startup = true;
    };
    adb.enable = true;
    ugrep.enable = true;
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
