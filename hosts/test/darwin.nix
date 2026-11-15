{
  pkgs,
  lib,
  my,
  ...
}:
{
  # user.name = "lyeli";
  nix = {
    settings.cores = 4;
  };
  user.uid = 501; # uid macos 创建的用户 默认 uid 为 501
  modules = {
    # shared

    # 原 tui 工具已按功能域拆散
    files.yazi.enable = true;
    files.archive.default = "ouch";
    tools.translate = {
      enable = true;
      deeplx = {
        enable = false;
        service.startup = false;
      };
    };
    services.download.aria2 = {
      service.startup = false;
      aria2p = false;
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
        cmus.enable = true;
        musikcube.enable = true;
      };
    };
    services.media.mpd = {
      default = "ncmpcpp";
      service.startup = false;
    };
    services.nginx = {
      enable = true;
      workDir = "/opt/nginx";
      www.enable = true;
    };
    services.proxy = {
      default = "sing-box";
      sing-box.package = pkgs.sing-box;
      clash.enable = true;
      service.enable = true;
      service.startup = false;
      configFile = "${my.paths.homedir}/Nutstore Files/我的坚果云/clash/singbox.json";
    };

    services.files.alist = {
      enable = false;
      service.startup = false;
    };

    files.rsync.enable = true;
    # app（前台应用）
    network.qbittorrent = {
      enGui = false;
      service = {
        startup = false;
        enable = true;
      };
    };
    editor = {
      emacs = {
        enable = true;
        service.enable = true;
      };

      default = "nvim";
      # nvim.enable = true;
      nvim.enGui = false; # GUI 编辑工具为emacs
      helix.enable = true;
      vscode.enable = true;
      zed.enable = true;
    };
    # gui（前台 GUI 应用）
    media.music.gtk.netease.enable = false;
    media.music.kew.enable = true;
    media.music.ncmpcpp.enable = true;
    media.music.rmpc.enable = true;
    media.flameshot.enable = true;
    media.video.default = "mpv";
    media.video.vlc.enable = true;
    shell.terminal = {
      default = "kitty";
      ghostty.enable = true;
      wezterm.enable = true;
      alacritty.enable = true;
    };

    network.localsend.enable = true; # 需要gui，局域网文件传输工具
    network.browser = {
      default = "firefox";
      # firefox.extensions = lib.mkForce [];
      fallback = "chrome";
      # fallback = pkgs.darwinapps.vivaldi;
    };

    shell = {
      prompt.default = "oh-my-posh";
      default = "zsh";
      bash.enable = true;
      fish.enable = true;
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

    tools.navi.enable = true;
    tools.fastfetch.enable = true;
    network.tg.enable = true;
    shell.tmux = {
      enable = true;
      service.startup = false;
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
    security.gopass = {
      enable = true;
      enGui = false;
    };
    files.trash.enable = true;
    dev.just.enable = true;

    tools.modern.enable = true;

    dev = {
      bash.enable = true;
      python = {
        enable = true;
        versions = [
          "3.12"
          "3.10"
          "3.11"
        ];
        global = "3.11";
        poetry.enable = true;
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
      enWebReport = true;
      rust.enable = true;
    };
    tools.rime.enable = true;
    # macos：非 service 域的 darwin 模块统一带 macos 层（后续 shared 出现同名文件时即为兼容层）
    macos = {
      brew.mirror = "tuna";
      dev = {
        docker.enable = true;
        wine.enable = true;
      };
      media.music = {
        lx.enable = true;
        apprhyme.enable = true;
        spotube.enable = true;
        fifo.enable = true;
      };
      network = {
        safari.enable = true;
        netdriver.enable = true;
      };
      tools = {
        read.enable = true;
        games.enable = true;
        hammerspoon.enable = true;
        duti.enable = true;
        chat.enable = true;
        clear.enable = true;
        ui.ice.enable = true;
      };
    };
    # macOS 独有的 service 去掉 macos 层
    services.battery.enable = true;
    services.yabai.enable = true;
    services.karabiner.enable = true;
    services.syncthing.enable = true;
  };
  system.stateVersion = lib.mkForce 5;
}
