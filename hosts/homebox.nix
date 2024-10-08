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
    package = pkgs.nixVersions.latest;
    # maxJobs = 4;
    settings.cores = 4;
  };
  user.uid = 501; # uid macos 创建的用户 默认 uid 为 501
  modules = {
    # shared

    # tui 工具
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
        aria2p = true;
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
        default = "mpd";
        netease.enable = true;
        mpd.service.startup = true;
        cmus.enable = true;
        musikcube.enable = true;
        mpd.default = "ncmpcpp";
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
      sing-box.package = pkgs.unstable.sing-box;
      service.enable = true;
      configFile = "${config.user.home}/Nutstore Files/我的坚果云/clash/singbox.json";
    };

    alist = {
      enable = true;
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

      editor = {
        emacs = {
          enable = true;
          service.enable = true;
        };

        default = "nvim";
        # app.editor.nvim.enable = true;
        nvim.enGui = false; # GUI 编辑工具为emacs
        vscode.enable = true;
      };
    };

    # gui
    gui = {
      terminal.default = "kitty";

      localsend.enable = true; # 需要gui，局域网文件传输工具

      browser.default = "firefox";
      # browser.firefox.extensions = lib.mkForce [];
      browser.fallback = "chrome";
      # browser.fallback = pkgs.unstable.darwinapps.vivaldi;
      media = {
        flameshot.enable = true;
        music.netease.enable = false;

        video.default = "mpv";
      };
    };

    shell = {
      prompt.default = "oh-my-posh";
      default = "zsh";
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

    modern.enable = true;

    # media.music.enable = true;
    # media.music.netease.enGui = false;
    # media.video.enable = true;

    dev = {
      bash.enable = true;

      python = {
        enable = true;
        versions = ["3.12" "3.10" "3.11"];
        global = "3.11";
        manager = "rye";
        rye.manager = true;
      };

      nix.enable = true;
      java = {
        enable = true;
        versions = ["oracle-21.0.1" "liberica-8u392+9"];
        global = "oracle-21.0.1";
      };
      lua.enable = true;
      cc.enable = true;
      node.enable = true;
      toml.fmt = true;
      enWebReport = true;
      rust.enable = true;
    };

    # macos
    macos = {
      enable = true;
      docker.enable = true;
      app.enable = true;
      arc.enable = true;
      karabiner.enable = true;
      safari.enable = true;
      stopAutoReopen = true;
      # music.lx.enable = true;
      music.apprhyme.enable = true;
      # music.spotube.enable = true;

      games.enable = true;
      hammerspoon.enable = true;
      rime.enable = true;
      brew.mirror = "tuna";
      duti.enable = true;
      netdriver.enable = true;
      chat.enable = true;
      # chat.local.enable = true;
    };

    nh = {
      enable = true;
    };
    service = {
      battery.enable = false;
      yabai.enable = true;
    };
  };
  # 如果你想使用macos别名请查看
  # https://github.com/LnL7/nix-darwin/issues/139#issuecomment-1230728610
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config =$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig                 = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild chang/nix/store/6xnavkbxd3kkkyssqds9p9rw9r47cj1q-gnupg-2.4.1/bin/gpg-connect-agentelog
  system.stateVersion = 4;

  # squoia-nixbld-user-migration.sh
}
