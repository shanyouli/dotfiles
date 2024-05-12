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
  mirrors = {
    bfsu = "https://mirrors.bfsu.edu.cn"; # 北外
    tuna = "https://mirrors.tuna.tsinghua.edu.cn"; # 清华
    sust = "https://mirrors.sustech.edu.cn"; # 南方科技大学
    nju = "https://mirror.nju.edu.cn"; # 浙江大学
  };
  can_mirror_taps = ["cask" "core" "services" "command-not-found"]; # cask-fonts
in {
  options.modules.macos.brew = {
    enable = mkBoolOpt true;
    useMirror = mkBoolOpt true;
    mirror = mkOption {
      type = types.str;
      default = "bfsu";
      apply = str:
        if builtins.hasAttr str mirrors
        then str
        else "bfsu";
    };
    description = "homebrew 使用 mirror";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (! cfg.useMirror) {
      homebrew.taps = map (x: "homebrew/" + x) can_mirror_taps;
    })
    (mkIf cfg.useMirror (let
      domain = mirrors."${cfg.mirror}";
      need_git =
        if cfg.mirror == "sust"
        then ""
        else "git/";
      fmtfunc = x: {
        name = "homebrew/" + x;
        clone_target = domain + "/" + need_git + "homebrew/homebrew-" + x + ".git";
      };
    in {
      homebrew.taps = map fmtfunc can_mirror_taps;
      modules.shell.rcInit = ''
        export HOMEBREW_INSTALL_FROM_API=1

        export HOMEBREW_API_DOMAIN="${domain}/homebrew-bottles/api"
        export HOMEBREW_BOTTLE_DOMAIN="${domain}/homebrew-bottles"

        export HOMEBREW_PIP_INDEX_URL="${domain}/pypi/web/simple"

        export HOMEBREW_BREW_GIT_REMOTE="${domain}/${need_git}homebrew/brew.git"
        export HOMEBREW_CORE_GIT_REMOTE="${domain}/${need_git}homebrew/homebrew-core.git"
      '';
    }))
    {
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
      homebrew.brewPrefix = let
        inherit (pkgs.stdenvNoCC) isAarch64 isAarch32;
      in (
        if isAarch64 || isAarch32
        then "/opt/homebrew/bin"
        else "/usr/local/bin"
      );
      homebrew.taps = ["buo/cask-upgrade"];

      homebrew.casks =
        [
          "raycast" # 取代 spotlight
          "stats" # 状态显示
          "forkgram-telegram"
          "baidunetdisk"
          "easydict" # 翻译软件
          "jetbrains-toolbox"
          # "syncthing" 同步
          # "downie"
          # # 使用第三方工具取代openmtp，MacDroid.app
          # (lib.mkIf config.modules.adb.enable
          #   "openmtp") # 或者
          "lulu" # 网络管理
          # "microsoft-office" , 手动安装
          "cryptomator"
          # "picgo" 使用 upic取代
          "wechat"
          "wpsoffice-cn"
          "mactex"

          # "calibre" #"koodo-reader", 书籍管理和阅读
          "skim" # PDF

          "imageoptim" # 图片压缩
          #
          "displaperture" # screen 曲线图
          "licecap" # GIF kap
          # "imazing" # 手机备份管理
          "arc"
          (mkIf (! config.modules.media.flameshot.enable) "shottr") # 截图
          # "betterdisplay" # 其他替代工具
          # "dozer" # 菜单栏管理,
          "maczip" # 压缩解压GUI
          # "fluent-reader" # RSS 阅读工具 or "netnewswire", 改用rss插件
          "squirrel" # 输入法
          "findergo" # 快捷方式，在finder中打开终端
          # "coconutbattery" # 电量查看
          "zotero" # 文献管理

          # "warp" # next terminal, 不太好用

          "syntax-highlight"
          "qlmarkdown"

          "playcover-community" # 侧载工具

          "mac-mouse-fix" # 鼠标fix
          "pictureview" # 看图

          "appcleaner" # 软件卸载
          "clean-me" # ka

          "charles" # "proxyman", 抓包
          "genymotion" # android 模拟工具 # "utm" # 开源虚拟工具
          "background-music" # 和一些工具冲突，eg mpd， yesplaymusic

          "postman" # "rapidapi" "httpie"
          # "arctype" # 数据库mysql, postgres,SQLite等，.medis2 redis, # TablePlus
          "sequel-ace" # mysql

          # "monitorcontrol" # 亮度控制和音量控制, 使用 hammerspoon取代
          # "maccy" # clip 剪切薄，使用raycast取代
          # "visual-studio-code" # other editors nix 管理
          (mkIf config.modules.shell.git.enGui "github") # github客户端
          (mkIf config.modules.browser.chrome.useBrew "google chrome")
          "command-x" # Cut files
          "tencent-lemon" # 文件清理
        ]
        ++ optionals config.modules.shell.adb.enable [
          # "openmtp" # 目前不是很稳定
          # “macdroid” # 付费app，使用adb传输，稳定性存疑
          # "android-file-transfer" # 可用，稳定性一般
          "whoozle-android-file-transfer" # 速度一般，稳定
          # "commander-one" # 速度可以，大文件也稳定，需要付费
        ];
      homebrew.brews = [
        # "macos-trash" # trash-cli
        # "mysql"
      ];
      homebrew.masApps = {
        "Userscript" = 1463298887; # tampermonkey
        "Amphetamine" = 937984704;
        # "mineweeper" = 1475921958;
        "immersive-translate" = 6447957425;
        "vimari" = 1480933944;
        # "adblock" = 1018301773;
        "text-scaner" = 1452523807;
        "medis2" = 1579200037;
        "vidhub" = 1659622164; # 视频管理,需要网速足够好
        "medis" = 1579200037; # redis 管理工具
        "devhub" = 6476452351; # 试用小工具合集
      };
    }
  ]);
}
