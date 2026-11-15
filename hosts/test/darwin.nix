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

      # 比较后选择
      # media.music.ncmpcpp.enable = true;
    };
    services.media.mpd = {
      service.startup = true;
      default = "ncmpcpp";
    };
    services.nginx = {
      enable = true;
      workDir = "/opt/nginx";
      www.enable = true;
    };
    services.proxy = {
      default = "sing-box";
      sing-box.package = pkgs.sing-box;
      service.enable = true;
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
      vscode.enable = true;
      zed.enable = true;
    };
    # gui（前台 GUI 应用）
    media = {
      music.gtk.netease.enable = false;
      flameshot.enable = true;

      video.default = "mpv";
    };
    shell.terminal.default = "kitty";

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
      fmt = {
        toml.enable = true;
      };
      enWebReport = true;
      rust.enable = true;
    };
    tools.rime.enable = true;
    # macos
    macos = {
      docker.enable = true;
      arc.enable = true;
      safari.enable = true;
      music = {
        lx.enable = true;
        apprhyme.enable = true;
        spotube.enable = true;
      };

      read.enable = true;
      games.enable = true;
      hammerspoon.enable = true;
      brew.mirror = "tuna";
      duti.enable = true;
      netdriver.enable = true;
      chat.enable = true;
      wine.enable = true;
      ui.ice.enable = true;
    };
    service = {
      battery.enable = true;
      yabai.enable = true;
      karabiner.enable = true;
    };
  };
  system.stateVersion = lib.mkForce 5;
}
