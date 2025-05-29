{
  pkgs,
  lib,
  my,
  config,
  options,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.brew;
  mirrors = {
    bfsu = "https://mirrors.bfsu.edu.cn"; # 北外
    tuna = "https://mirrors.tuna.tsinghua.edu.cn"; # 清华
    sust = "https://mirrors.sustech.edu.cn"; # 南方科技大学
    nju = "https://mirror.nju.edu.cn"; # 浙江大学
  };
  can_mirror_taps = [
    "cask"
    "core"
    "services"
    "command-not-found"
  ]; # cask-fonts
in
{
  options.modules.macos.brew = {
    enable = mkBoolOpt true;
    gui.enable = mkBoolOpt true; # homebrew GUI 显示工具
    useMirror = mkBoolOpt true;
    mirror = mkOption {
      type = types.str;
      default = "bfsu";
      apply = str: if builtins.hasAttr str mirrors then str else "bfsu";
    };
    description = "homebrew 使用 mirror";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (!cfg.useMirror) { homebrew.taps = map (x: "homebrew/" + x) can_mirror_taps; })
    (mkIf cfg.useMirror (
      let
        domain = mirrors."${cfg.mirror}";
        need_git = if cfg.mirror == "sust" then "" else "git/";
        fmtfunc = x: {
          name = "homebrew/" + x;
          clone_target = domain + "/" + need_git + "homebrew/homebrew-" + x + ".git";
        };
      in
      {
        homebrew.taps = map fmtfunc can_mirror_taps;

        # 不使用 api 来获取安装信息
        modules.shell.env = {
          HOMEBREW_NO_INSTALL_FROM_API = "1";
          # 不自动更新 brew 仓库
          # modules.shell.env.HOMEBREW_NO_AUTO_UPDATE = "1"; # or homebrew.global.autoUpdate = 1
          HOMEBREW_API_DOMAIN = "${domain}/homebrew-bottles/api";
          HOMEBREW_BOTTLE_DOMAIN = "${domain}/homebrew-bottles";
          HOMEBREW_PIP_INDEX_URL = "${domain}/pypi/web/simple";
          HOMEBREW_BREW_GIT_REMOTE = "${domain}/${need_git}homebrew/brew.git";
          HOMEBREW_CORE_GIT_REMOTE = "${domain}/${need_git}homebrew/homebrew-core.git";
        };
      }
    ))
    {
      # see @https://github.com/malob/nixpkgs/raw/f4e414d9debe099ecce51fc5df863ce235170306/darwin/homebrew.nix#L16
      # see @https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
      programs.fish.interactiveShellInit =
        let
          homebrew-home = removeSuffix "/bin" config.homebrew.brewPrefix;
        in
        ''
          if test -d "${homebrew-home}/share/fish/completions"
            set -p fish_complete_path ${homebrew-home}/share/fish/completions
          end
          if test -d "${homebrew-home}/share/fish/vendor_completions.d"
            set -p fish_complete_path ${homebrew-home}/share/fish/vendor_completions.d
          end
        '';
      homebrew = {
        enable = true; # 你需要手动安装homebrew
        onActivation = {
          autoUpdate = false;
          cleanup = "zap";
        };
        global = {
          brewfile = true;
          lockfiles = true;
          autoUpdate = false;
          # noLock = true;
        };
        brewPrefix =
          let
            inherit (pkgs.stdenvNoCC) isAarch64 isAarch32;
          in
          if isAarch64 || isAarch32 then "/opt/homebrew/bin" else "/usr/local/bin";
        taps = [
          "buo/cask-upgrade"
          "shanyouli/tap"
        ];
        casks =
          [
            "raycast" # 取代 spotlight
            # "stats" # 状态显示, 目前无法显示温度。
            "macs-fan-control" # 用来控制 fan 的工具
            # "forkgram-telegram"
            "easydict" # 翻译软件
            "jetbrains-toolbox"
            # "syncthing" 同步
            # "downie"
            "lulu" # 网络管理
            "veracrypt" # "cryptomator" # 即时加密软件
            "macfuse" # veracrypt 需要的工具

            "wechat"
            "wpsoffice-cn" # "microsoft-office" , 手动安装
            "mactex"

            # "displaperture" # screen 曲线图
            # "imageoptim" # 图片压缩
            # "licecap" # GIF kap
            # "imazing" # 手机备份管理
            (mkIf (!config.modules.gui.media.flameshot.enable) "shottr") # 截图
            "betterdisplay" # 其他替代工具
            "shanyouli/tap/stillcolor"
            # "monitorcontrol" # 亮度控制和音量控制, 使用 hammerspoon取代
            "maczip" # 压缩解压GUI
            # "fluent-reader" # RSS 阅读工具 or "netnewswire", 改用rss插件
            "findergo" # 快捷方式，在finder中打开终端
            "zotero" # 文献管理

            # "warp" # next terminal, 不太好用

            "syntax-highlight"
            "qlmarkdown"

            # "playcover-community" # 侧载工具

            "mac-mouse-fix" # 鼠标fix
            "pictureview" # 看图

            "tencent-lemon" # 文件清理 or ""clean-me""
            "pearcleaner" # app 卸载工具 or "appcleaner"

            "charles" # "proxyman", 抓包
            "genymotion" # android 模拟工具 # "utm" # 开源虚拟工具
            "background-music" # 和一些工具冲突，eg mpd， yesplaymusic

            "postman"
            "rapidapi" # "httpie"
            "reqable"

            "paragon-ntfs"

            # "arctype" # 数据库mysql, postgres,SQLite等，.medis2 redis, # TablePlus
            # "sequel-ace" # mysql
            # "navicat-premium"

            # "maccy" # clip 剪切薄，使用raycast取代
            # "visual-studio-code" # other editors nix 管理
            # "command-x" # Cut files, need upgrade
            "logseq" # 笔记工具

            "markedit" # markdown 编辑器

            # "windterm" # 比较好用的 ssh 客户端，可以使用 vscode 的 ssh 插件取代
            # "doll" # 在 menubar 上显示 消息提示
            # "zed" # 还是没有 vscode 好用
            # "qutebrowser" # 浏览器
            "zen"

            "shanyouli/tap/upic" # or "picgo"

            "shanyouli/tap/quickrecorder" # 录屏
            "shanyouli/tap/tmexclude"

            "shanyouli/tap/vimmotion" # 使用 vim 全局操作
            "shanyouli/tap/airbattery" # 设备电量显示

            "bbackupp" # ios 备份工具 #
          ]
          ++ optionals config.modules.adb.enable [
            # # 使用第三方工具取代openmtp，MacDroid.app
            # "openmtp" # 目前不是很稳定
            # “macdroid” # 付费app，使用adb传输，稳定性存疑
            # "android-file-transfer" # 可用，稳定性一般
            # "commander-one" # 速度可以，大文件也稳定，需要付费
            # "whoozle-android-file-transfer" # 速度一般，稳定
          ]
          ++ optionals config.modules.gopass.enable [ "ente-auth" ]
          ++ optionals (
            config.modules.gui.browser.chrome.enable && config.modules.gui.browser.chrome.useBrew
          ) [ "google-chrome" ]
          ++ optionals (config.modules.git.enable && config.modules.git.enGui) [
            "github" # github客户端
          ]
          # ++ optionals (config.modules.app.editor.nvim.enGui && config.modules.app.editor.nvim.enable) [
          #   "shanyouli/tap/neovide"
          # ]
          # ++ optionals (config.modules.gui.enable && (config.modules.proxy.default != "")) [
          # 使用 macos 商店的工具取代它
          #   # "shanyouli/tap/clash-verge"
          #   # (mkIf (config.modules.proxy.default == "sing-box") "sfm")
          # ]
          ++ optionals cfg.gui.enable [
            "applite"
            (mkIf (config.modules.proxy.default == "sing-box") "shanyouli/tap/gui-for-singbox")
            # (mkIf (config.modules.proxy.default == "clash") "shanyouli/tap/gui-for-clash")
            "clash-verge-rev"
          ];
        brews = [
          # "mysql"
          "mist-cli"
          "p7zip" # "Rpc3 依赖工具"
        ];
        masApps = mkMerge [
          (mkIf (config.modules.gui.enable && (config.modules.proxy.default != "")) {
            karing = 6472431552; # 美区账号登录，一个兼容 clash-meta 的 sing-box vpn 工具
          })
          {
            "Amphetamine" = 937984704; # 咖啡因，防止系统休眠
            "text-scaner" = 1452523807; # 文本扫描
            "pipad-calc" = 1482575592; # 高颜值的计算器
            # "vidhub" = 1659622164; # 视频管理,需要网速足够好
            # "medis" = 1579200037; # redis 管理工具, 可免费使用，
            # "devhub" = 6476452351; # 试用小工具合集
            # "mineweeper" = 1475921958; # 扫雷
          }
        ];
      };
    }
  ]);
}
