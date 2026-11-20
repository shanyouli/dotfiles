{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  # 桌面真机目标：启用尽可能多的模块（含 GUI），把求值/构建面铺满。
  modules = {
    # GUI 总开关：media.video / shell.terminal / gopass 的 enGui 等都挂在它上面
    fonts.enable = true;

    editor = {
      default = "nvim";
      helix.enable = true;
      emacs.enable = true;
      vscode.enable = true;
      zed.enable = true;
    };

    dev = {
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
      };
      js.enable = true;
      go.enable = true;
      scheme.enable = true;
      zig.enable = true;
      jujutsu.enable = true;
      nh.enable = true;
      lix.enable = true;
      ai.enable = true;
      fmt = {
        toml.enable = true;
        python.enable = true;
        bash.enable = true;
        lua.enable = true;
        fennel.enable = true;
        nix.enable = true;
        markdown.enable = true;
        js-beautify.enable = true;
      };
    };

    shell = {
      default = "zsh";
      bash.enable = true;
      fish.enable = true;
      nushell.enable = true;
      carapace.enable = true;
      direnv.enable = true;

      prompt.default = "oh-my-posh";
      nix-your-shell.enable = true;
      zsh.zinit.enable = true;

      vivid.enable = true;
      zoxide.enable = true;
      atuin.enable = true;
      nix-index.enable = true;

      terminal = {
        default = "kitty";
        ghostty.enable = true;
        wezterm.enable = true;
        alacritty.enable = true;
      };

      tmux = {
        enable = true;
        service.startup = false;
      };
    };

    files = {
      archive.default = "ouch";
      rsync.enable = true;
      trash.enable = true;
      yazi.enable = true;
    };

    tools = {
      navi.enable = true;
      adb.enable = true;
      ugrep.enable = true;
      db.enable = true;
      modern.enable = true;
      fastfetch.enable = true;
      rime.enable = true;
      herdr.enable = true;
      translate = {
        enable = true;
        deeplx = {
          enable = false;
          service.startup = false;
        };
      };
    };

    media = {
      enable = true;
      stream.enable = true;
      flameshot.enable = true;
      music = {
        default = "mpd";
        netease.enable = true;
        cmus.enable = true;
        kew.enable = true;
        musikcube.enable = true;
        ncmpcpp.enable = true;
      };
      video = {
        default = "mpv";
        vlc.enable = true;
      };
    };

    network = {
      browser = {
        default = "firefox";
        chrome.enable = true;
      };
      localsend.enable = true;
      tg.enable = true;
      qbittorrent = {
        enable = true;
        enGui = true;
      };
    };

    services = {
      db.mysql = {
        enable = true;
        service.startup = false;
      };
      download.aria2 = {
        enable = true;
        service.startup = false;
      };
      media.mpd = {
        default = "ncmpcpp";
        service.startup = false;
      };
      nginx = {
        enable = true;
        workDir = "/opt/nginx";
        www.enable = true;
        service.startup = false;
      };
      proxy = {
        default = "sing-box";
        clash.enable = true;
        service.enable = true;
        service.startup = false;
      };
      files.alist = {
        enable = false;
        service.startup = false;
      };
    };

    security.gpg = {
      enable = true;
      cacheTTL = 360000;
    };
    security.gopass = {
      enable = true;
      enGui = true;
    };
    dev.git = {
      enable = true;
      enGui = true;
    };
    dev.just.enable = true;
  };
}
