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
  user.uid = 501; # uid macos 创建的用户 默认 uid 为 501
  # modules.macos.brew.enable = false;
  modules = {
    # shared

    # 原 tui 工具已按功能域拆散
    shell.m.enable = true;
    files.yazi.enable = true;
    dev.lix.enable = true;
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
    # media.music.ncmpcpp.enable = true;

    services.nginx = {
      enable = true;
      workDir = "/opt/nginx";
      www.enable = true;
    };

    services.proxy = {
      default = "clash";
      service = {
        enable = true;
        startup = false;
      };
      configFile = "${my.paths.homedir}/Nutstore Files/我的坚果云/代理相关/singbox.json";
    };

    services.files.alist = {
      enable = false;
      service.startup = false;
    };

    files.rsync.enable = true;
    # app（前台应用）
    network.qbittorrent = {
      enGui = false;
      service.startup = false;
      service.enable = true;
    };
    network.tg = {
      enable = true;
      package = null;
    };
    editor = {
      emacs = {
        enable = true;
        service.enable = false;
        package = pkgs.emacs-unstable;
      };

      default = "nvim";
      nvim.treesit = "all";
      nvim.enGui = false; # GUI 编辑工具为emacs
      vscode.enable = true;
      # zed = {
      #   # package = pkgs.unstable.zed-editor;
      #   package = null;
      #   enable = true;
      # };
    };

    # # gui（前台 GUI 应用）
    shell.terminal.default = "ghostty";
    # shell.terminal.ghostty.enable = true;

    network.localsend.enable = true; # 需要gui，局域网文件传输工具

    network.browser.default = "chrome"; # firefox
    # network.browser.firefox.extensions = lib.mkForce [];
    # network.browser.fallback = "chrome";
    # network.browser.fallback = pkgs.darwinapps.vivaldi;
    media.flameshot.enable = true;
    media.music.gtk.netease.enable = false;

    media.video.default = "mpv";

    shell = {
      prompt = {
        default = "starship";
        zsh.enable = true;
      };
      default = "zsh";
      # fish.enable = true;
      # zsh.enable = true;
      bash.enable = true;
      nushell = {
        enable = true;
        package = pkgs.unstable.nushell;
      };
      carapace.enable = true;
      nix-your-shell.enable = true;
      zsh.zinit.enable = true;

      vivid.enable = true;
      zoxide.enable = true;
      atuin.enable = true;
      nix-index.enable = true;
      direnv.enable = true;
    };

    tools.navi.enable = true;
    shell.multiplexer.default = "herdr";
    tools.adb.enable = true;
    # ugrep.enable = true;
    security.gpg = {
      enable = true;
      cacheTTL = 360000;
    };
    dev.jujutsu.enable = true;
    dev.git = {
      enable = true;
      enGui = false; # 使用网页管理 github
    };
    security.gopass = {
      enable = true;
      enGui = false;
      browsers = [ "glide" ];
    };
    files.trash.enable = true;
    dev.just.enable = true;

    tools.modern.enable = true;

    dev = {
      bash.enable = true;
      go.enable = true;
      manager.package = pkgs.unstable.mise;
      python = {
        enable = true;
        versions = [
          "3.14"
          "3.13"
          "3.11"
          "3.12"
        ];
        global = "3.12";
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
        enable = true;
        fmt.package = pkgs.unstable.oxfmt;
        lint.package = pkgs.unstable.oxlint;
      };
      fmt = {
        toml.enable = true;
      };
      enWebReport = true;
      rust.enable = true;
      scheme.enable = true;
      ai.enable = true;
      zig.enable = true;
    };
    tools.rime = {
      enable = true;
      method = "frost";
    };
    # macos：非 service 域的 darwin 模块统一带 macos 层（后续 shared 出现同名文件时即为兼容层）
    macos = {
      brew.mirror = "sust";
      # relaunchApp.enable = true;
      dev = {
        docker.enable = true;
        wine = {
          enable = true;
          crossover.enable = true;
        };
      };
      editor.enable = true;
      network = {
        safari.enable = true;
        netdriver.enable = true;
      };
      tools = {
        clear.enable = true;
        games.enable = true;
        hammerspoon.enable = true;
        duti.enable = false; # use openwith command
        read.enable = true;
        rime.enable = false;
        chat = {
          enable = true;
          snapbox.enable = false;
          local.enable = lib.mkForce false;
        };
        finder.enable = true;
        # ui.ice.enable = true;
      };
      # media.music 相关暂未启用（兼容层：options 默认值取自 shared）
      # media.music.lx.enable = true;
      # media.music.apprhyme.enable = true;
      # media.music.spotube.enable = true;
    };

    # macOS 独有的 service 去掉 macos 层
    services.battery.enable = false; # use aldente
    services.karabiner = {
      enable = true;
      package = null;
    };
    services.yabai = {
      enable = true;
      package = pkgs.darwinapps.yabai;
      border.enable = false;
      keep.enable = false;
    };

    dev.nh = {
      enable = true;
    };
  };
  system.stateVersion = lib.mkForce 5;
}
