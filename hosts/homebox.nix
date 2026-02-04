{
  pkgs,
  lib,
  my,
  ...
}:
{
  # user.name = "lyeli";
  nix = {
    # maxJobs = 4;
    settings.cores = 4;
  };
  user.packages = [ pkgs.librewolf ];
  user.uid = 501; # uid macos 创建的用户 默认 uid 为 501
  # modules.macos.brew.enable = false;
  modules = {
    # shared

    # tui 工具
    tui = {
      yazi.enable = true;
      lix.enable = true;
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

    # 比较后选择
    media = {
      enable = true;
      stream.enable = true;
      music = {
        default = "kew";
        netease.enable = true;
        # mpd.service.startup = true;
        # kew.enable = true;
        # musikcube.enable = true;
        # mpd.default = "ncmpcpp";
      };
    };
    # media.music.mpd.ncmpcpp.enable = true;

    nginx = {
      enable = true;
      workDir = "/opt/nginx";
      www.enable = true;
    };

    proxy = {
      default = "sing-box";
      sing-box.package = pkgs.sing-box;
      service = {
        enable = true;
        startup = false;
      };
      configFile = "${my.homedir}/Nutstore Files/我的坚果云/代理相关/singbox.json";
    };

    alist = {
      enable = false;
      service.startup = false;
    };

    rsync.enable = true;
    # app
    app = {
      qbittorrent = {
        enGui = false;
        service.startup = false;
        service.enable = true;
      };
      tg = {
        enable = true;
        package = pkgs.ayugram-desktop;
      };
      editor = {
        emacs = {
          enable = true;
          service.enable = false;
          rime.ice.enable = true;
          package = pkgs.emacs;
        };

        default = "nvim";
        nvim.treesit = "all";
        nvim.enGui = false; # GUI 编辑工具为emacs
        vscode.enable = true;
        zed = {
          # package = pkgs.zed-editor;
          enable = true;
        };
      };
    };

    # # gui
    gui = {
      terminal.default = "ghostty";
      # terminal.ghostty.enable = true;

      localsend.enable = true; # 需要gui，局域网文件传输工具

      browser.default = "firefox";
      # browser.firefox.extensions = lib.mkForce [];
      browser.fallback = "chrome";
      # browser.fallback = pkgs.darwinapps.vivaldi;
      media = {
        flameshot.enable = true;
        music.netease.enable = false;

        video.default = "mpv";
      };
    };

    shell = {
      prompt.default = "oh-my-posh";
      default = "zsh";
      # fish.enable = true;
      # zsh.enable = true;
      bash.enable = true;
      nushell.enable = true;
      carapace.enable = true;
      nix-your-shell.enable = true;
      zsh.zinit.enable = true;

      vivid.enable = true;
      zoxide.enable = true;
      atuin.enable = true;
      nix-index.enable = true;
      direnv.enable = true;
    };

    navi.enable = true;
    tmux = {
      enable = true;
      service.startup = true;
    };
    adb.enable = true;
    # ugrep.enable = true;
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

    modern.enable = true;

    dev = {
      bash.enable = true;
      go.enable = true;

      python = {
        enable = true;
        versions = [
          "3.14"
          "3.13"
          "3.11"
          "3.12"
        ];
        global = "3.12";
        venv = "uv";
      };

      nix.enable = true;
      java = {
        enable = true;
        versions = [
          "oracle-21.0.1"
          "liberica-8u392+9"
        ];
        global = "oracle-21.0.1";
      };
      lua.enable = true;
      cc.enable = true;
      js = {
        node.enable = true;
        bun.enable = true;
      };
      toml.fmt = true;
      enWebReport = true;
      rust.enable = true;
      scheme.enable = true;
      ai.enable = true;
    };

    rime.method = "wanxiang";
    # macos
    macos = {
      enable = true;
      docker.enable = true;
      # arc.enable = true;
      karabiner.enable = true;
      safari.enable = true;
      # relaunchApp.enable = true;
      # music.lx.enable = true;
      # music.apprhyme.enable = true;
      # music.spotube.enable = true;

      games.enable = true;
      hammerspoon.enable = true;
      rime.enable = true;
      brew.mirror = "sust";
      duti.enable = true;
      netdriver.enable = true;
      chat = {
        enable = true;
        nextchat.enable = false;
        snapbox.enable = false;
        local.enable = lib.mkForce false;
      };
      # ui = {
      #   ice.enable = true;
      # };
      wine = {
        enable = true;
        crossover.enable = true;
      };
      read.enable = true;
    };

    nh = {
      enable = true;
    };
    service = {
      battery.enable = false;
      yabai = {
        enable = true;
        border.enable = false;
      };
    };
  };
  system.stateVersion = lib.mkForce 5;
}
