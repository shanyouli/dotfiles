{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.brew;
  mirrors = ["bfsu" "tuna"];
in {
  options.modules.macos.brew = {
    enable = mkBoolOpt true;
    useMirror = mkBoolOpt true;
    mirror = mkOption {
      type = types.nullOr types.str;
      default = "bfsu";
      apply = str:
        if builtins.elem str mirrors
        then str
        else "bfsu";
    };
    description = ''
      homebrew 使用 mirror
    '';
  };

  config = mkIf cfg.enable {
    homebrew.enable = true; # 你需要手动安装homebrew
    homebrew.onActivation = {
      autoUpdate = false;
      cleanup = "zap";
    };
    homebrew.global = {
      brewfile = true;
      lockfiles = true;
      # noLock = true;
    };
    homebrew.taps =
      (
        if cfg.useMirror
        then
          (let
            domain =
              if cfg.mirror == "bfsu"
              then "https://mirrors.bfsu.edu.cn"
              else "https://mirrors.tuna.tsinghua.edu.cn";
          in [
            {
              name = "homebrew/cask";
              clone_target = "${domain}/git/homebrew/homebrew-cask.git";
            }
            {
              name = "homebrew/core";
              clone_target = "${domain}/git/homebrew/homebrew-core.git";
            }
            {
              name = "homebrew/services";
              clone_target = "${domain}/git/homebrew/homebrew-services.git";
            }
            {
              name = "homebrew/cask-versions";
              clone_target = "${domain}/git/homebrew/homebrew-cask-versions.git";
            }
            {
              name = "homebrew/command-not-found";
              clone_target = "${domain}/git/homebrew/homebre-command-not-found.git";
            }
          ])
        else [
          "homebrew/cask"
          "homebrew/core"
          "homebrew/services"
          "homebrew/cask-versions"
          "homebrew/command-not-found"
          # "homebrew/cask-fonts" 不需要使用, 使用nix控制安装字体
        ]
      )
      ++ ["buo/cask-upgrade"];
    homebrew.casks = [
      "raycast" # 取代 spotlight
      "stats" # 状态显示
      "telegram"
      "baidunetdisk"
      "orbstack" # docker
      "easydict" # 翻译软件
      "jetbrains-toolbox"
      # "syncthing" 同步
      # "downie"
      # # 使用第三方工具取代openmtp，MacDroid.app
      # (lib.mkIf config.modules.adb.enable
      #   "openmtp") # 或者  "android-file-transfer"
      "lulu" # 网络管理
      # "microsoft-office" , 手动安装
      "cryptomator"
      # "picgo" 使用 upic取代
      "wechat"
      "wpsoffice-cn"
      "mactex"

      "calibre" #"koodo-reader", 书籍管理和阅读
      "skim" # PDF

      "imageoptim" # 图片压缩
      #
      "displaperture" # screen 曲线图
      "licecap" # GIF kap
      # "imazing" # 手机备份管理
      # "shottr" # 截图
      # "betterdisplay" # 其他替代工具
      # "dozer" # 菜单栏管理,
      "maczip" # 压缩解压GUI
      # "fluent-reader" # RSS 阅读工具 or "netnewswire", 改用rss插件
      "squirrel" # 输入法
      "findergo" # 快捷方式，在finder中打开终端
      # "coconutbattery" # 电量查看
      "zotero" # 文献管理

      # "warp" # next terminal, 不太好用

      # "glance-chamburr" # finder 扩展
      "syntax-highlight"
      "qlmarkdown"

      "playcover-community" # 侧载工具

      "mac-mouse-fix" # 鼠标fix
      "pictureview" # 看图

      "appcleaner" # 软件卸载
      "clean-me" # ka

      "charles" # "proxyman", 抓包
      # "visual-studio-code" # other editors nix 管理
      "genymotion" # android 模拟工具 # "utm" # 开源虚拟工具
      "background-music"

      "postman" # "rapidapi" "httpie"
      # "arctype" # 数据库mysql, postgres,SQLite等，.medis2 redis, # TablePlus
      "sequel-ace" # mysql

      # "monitorcontrol" # 亮度控制和音量控制, 使用 hammerspoon取代
      # "maccy" # clip 剪切薄，使用raycast取代
      (mkIf config.modules.shell.git.enGui "github") # github客户端

      "chromedriver" # brave 浏览器的driver

      # "google-chrome"
      # "arc" # next browser
      "brave-browser"
    ];
    homebrew.brews = [
      "macos-trash" # trash-cli
      # "mysql"
    ];
    homebrew.masApps = {
      # "Userscript" = 1463298887; tampermonkey
      "OneTab" = 1540160809;
      "Amphetamine" = 937984704;
      "mineweeper" = 1475921958;
      "immersive-translate" = 6447957425;
      # "vimkey" = 1585682577; # replace vimari
      "adblock" = 1018301773;
      "text-scaner" = 1452523807;
      "medis2" = 1579200037;
      "vidhub" = 1659622164; # 视频管理,需要网速足够好
      "xnip" = 1221250572; # 截图
      "medis" = 1579200037; # redis 管理工具
    };
    modules.shell = mkMerge [
      {
        envInit =
          if pkgs.stdenvNoCC.isx86_64
          then "_cache /usr/local/bin/brew shellenv"
          else "_cache /opt/homebrew/bin/brew shellenv";
      }
      (mkIf cfg.useMirror {
        env = let
          domain =
            if cfg.mirror == "bfsu"
            then "https://mirrors.bfsu.edu.cn"
            else "https://mirrors.tuna.tsinghua.edu.cn";
        in {
          HOMEBREW_INSTALL_FROM_API = "1";
          HOMEBREW_API_DOMAIN = "${domain}/homebrew-bottles/api";
          HOMEBREW_BOTTLE_DOMAIN = "${domain}/homebrew-bottles";
          HOMEBREW_BREW_GIT_REMOTE = "${domain}/git/homebrew/brew.git";
          HOMEBREW_CORE_GIT_REMOTE = "${domain}/git/homebrew/homebrew-core.git";
          HOMEBREW_PIP_INDEX_URL = "${domain}/pypi/web/simple";
        };
      })
    ];
  };
}
