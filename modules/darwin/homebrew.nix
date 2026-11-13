{
  inputs,
  pkgs,
  lib,
  my,
  config,
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
in
{
  # 托管 homebrew 本体：钉死 brew 版本、自动接管已有安装（README "Existing Homebrew Installation"）
  # 注：包声明（casks/brews/masApps）仍由下方 homebrew.* 负责；
  #     taps 在 nix-homebrew.taps（提供只读 store 快照）与 homebrew.taps（让 bundle
  #     cleanup 不 untap）两处成对声明，新增 tap 时两边都要加；
  #     刻意不 pin homebrew-core/cask，保留 API 模式让包元数据自动更新
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

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
    {
      environment.etc."homebrew/brew.env".text = ''
        # 不自动更新
        HOMEBREW_NO_AUTO_UPDATE=1
        # 修改更新间隔
        HOMEBREW_AUTO_UPDATE_SECS=2678400
        HOMEBREW_API_AUTO_UPDATE_SECS=2678400
        # cat
        HOMEBREW_BAT=1
      '';
    }
    # (mkIf (!cfg.useMirror) { homebrew.taps = map (x: "homebrew/" + x) can_mirror_taps; })
    (mkIf cfg.useMirror (
      let
        domain = mirrors."${cfg.mirror}";
        need_git = if cfg.mirror == "sust" then "" else "git/";
      in
      {
        # homebrew.taps = map fmtfunc can_mirror_taps;
        # 不使用 api 来获取安装信息
        environment.etc."homebrew/brew.env".text = mkAfter ''
          HOMEBREW_API_DOMAIN=${domain}/homebrew-bottles/api
          HOMEBREW_BOTTLE_DOMAIN=${domain}/homebrew-bottles
          HOMEBREW_PIP_INDEX_URL=${domain}/pypi/web/simple
          # HOMEBREW_BREW_GIT_REMOTE=${domain}/${need_git}homebrew/brew.git
          # HOMEBREW_CORE_GIT_REMOTE=${domain}/${need_git}homebrew/homebrew-core.git
        '';
      }
    ))
    {
      # see @https://github.com/malob/nixpkgs/raw/f4e414d9debe099ecce51fc5df863ce235170306/darwin/homebrew.nix#L16
      # see @https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
      programs.fish.interactiveShellInit =
        let
          homebrew-home = config.homebrew.prefix;
        in
        ''
          if test -d "${homebrew-home}/share/fish/completions"
            set -p fish_complete_path ${homebrew-home}/share/fish/completions
          end
          if test -d "${homebrew-home}/share/fish/vendor_completions.d"
            set -p fish_complete_path ${homebrew-home}/share/fish/vendor_completions.d
          end
        '';
      # brew 本体与 taps 均由 nix-homebrew 托管（若此前用官方脚本安装，首次激活会由
      # autoMigrate 接管）：
      # - 升级 brew 走 `nix flake update nix-homebrew`，不再随 brew 自更新漂移
      # - taps 升级走 `nix flake update homebrew-tap-*`；mutableTaps = false 后
      #   `brew tap` 不再可用，Taps 目录整体指向 store（只读）
      # - 若上游 pin 的 brew-src 带 regression 导致 switch 失败，在本仓库 flake 中
      #   override nix-homebrew 的 brew-src input 指向修复版本
      # - HOMEBREW_NO_AUTO_UPDATE / AUTO_UPDATE_SECS 保留，语义变为只抑制包元数据
      #   （formula/cask 索引）自动更新，brew 自身版本与 taps 由 Nix 决定
      # - 不声明 homebrew/homebrew-core：保留 API 模式，HOMEBREW_API_DOMAIN 镜像对
      #   formula/cask 元数据继续生效，且元数据可自动更新；若声明 core，
      #   nix-homebrew 会设 HOMEBREW_NO_INSTALL_FROM_API=1 并改用 pinned 本地 core
      nix-homebrew = {
        enable = true;
        user = my.vars.user;
        # 自动迁移官方脚本安装的 /opt/homebrew，无需先卸载
        autoMigrate = true;
        # 完全声明式 taps：禁止命令式 `brew tap`
        mutableTaps = false;
        # key 为 Library/Taps 下的目录名（owner/homebrew-repo）
        taps = {
          "buo/homebrew-cask-upgrade" = inputs.homebrew-tap-buo;
          "shanyouli/homebrew-tap" = inputs.homebrew-tap-shanyouli;
        };
        # 非官方 tap 需显式信任（Homebrew 5 起强制）
        trust.taps = [
          "buo/cask-upgrade"
          "shanyouli/tap"
        ];
      };
      # NOTE: update homebrew activation script
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = false;
          cleanup = "zap";
          extraFlags = [ "--force-cleanup" ];
        };
        global = {
          brewfile = true;
          autoUpdate = false;
        };
        prefix =
          let
            inherit (pkgs.stdenvNoCC) isAarch64 isAarch32;
          in
          if isAarch64 || isAarch32 then "/opt/homebrew" else "/usr/local";
        # taps 必须同时在此声明：nix-darwin 以 `brew bundle --force-cleanup` 激活，
        # 其 cleanup 会把「已安装但 Brewfile 未声明」的 tap 交给 `brew untap`，
        # 而 Taps 已是只读 store 软链，会报 Permission denied。
        # 声明后 bundle 侧会因 Tap#installed? 直接跳过（不会 clone 只读目录）。
        taps = [
          {
            name = "buo/cask-upgrade";
            trusted = true;
          }
          {
            name = "shanyouli/tap";
            trusted = true;
          }
        ];
        casks = [
          "tinycast" # or "raycast" # 取代 spotlight

          # "stats" # 状态显示, 目前无法显示温度。
          "macs-fan-control" # 用来控制 fan 的工具
          "easydict" # 翻译软件
          "jetbrains-toolbox"
          # "syncthing" 同步
          # "downie"
          "lulu" # 网络管理
          "veracrypt" # "cryptomator" # 即时加密软件
          "macfuse" # veracrypt 需要的工具

          "wechat"
          "qq"
          "wpsoffice-cn" # "microsoft-office" , 手动安装

          # "mactex" # 使用 texlive 取代

          # "displaperture" # screen 曲线图
          # "imageoptim" # 图片压缩
          # "licecap" # GIF kap
          # "imazing" # 手机备份管理
          (mkIf (!config.modules.gui.media.flameshot.enable) "shottr") # 截图

          "crisp" # 开源的 "betterdisplay"  "monitorcontrol"替代方案

          "maczip" # 压缩解压GUI or "keka"

          # "findergo" # 快捷方式，在finder中打开终端
          "zotero" # 文献管理

          # "warp" # next terminal, 不太好用
          #
          # finder 插件
          "syntax-highlight"
          "qlmarkdown" # markdown
          "macpacker" # zip 文件预览

          # "playcover-community" # 侧载工具

          "mac-mouse-fix" # 鼠标fix or "mos"

          "pictureview" # 看图

          "charles" # "proxyman", 抓包

          "shanyouli/tap/macapk" # 安装 android 包, 一个比 “genymotion” 更好的替换工具

          # "utm" # 开源虚拟工具 不如 "pd"
          #
          "finetune" # 另一款各个音量app 使用 # "background-music" # 和一些工具冲突，eg mpd， yesplaymusic

          "postman"
          "rapidapi" # "httpie"
          "reqable"

          "paragon-ntfs"

          "logseq" # 笔记工具

          # "windterm" # 比较好用的 ssh 客户端，可以使用 vscode 的 ssh 插件取代

          "shanyouli/tap/upic" # or "picgo"

          "shanyouli/tap/quickrecorder" # 录屏

          "shanyouli/tap/tmexclude"

          # "shanyouli/tap/vimmotion" # 使用 vim 全局操作
          "shanyouli/tap/airbattery" # 设备电量显示

          "bbackupp" # ios 备份工具 #

          "shanyouli/tap/mountmate" # U 盘挂载管理工具

          ## 一些其他推荐应用
          ## 数据库
          # "arctype" # 数据库mysql, postgres,SQLite等，.medis2 redis, # TablePlus
          # "sequel-ace" # mysql
          "tablepro"
          # "navicat-premium"

          # "maccy" # clip 剪切薄，使用raycast取代
          "lite-edit" # "coteditor"
          "command-x" # Cut files, need upgrade

          ## 浏览器
          # "qutebrowser" #
          # "zen"
          "shanyouli/tap/bilibili-video-downloader"

          # "fluent-reader" # RSS 阅读工具 or "netnewswire", 改用rss插件
          "shanyouli/tap/mrrss"

          "glide-browser"
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
        #   "shanyouli/tap/neovide-pure"
        # ]
        # ++ optionals (config.modules.gui.enable && (config.modules.proxy.default != "")) [
        # 使用 macos 商店的工具取代它
        #   # (mkIf (config.modules.proxy.default == "sing-box") "sfm")
        # ]
        ++ optionals cfg.gui.enable [
          # "applite"
          (mkIf (config.modules.proxy.default == "sing-box") "shanyouli/tap/gui-for-singbox")
          # (mkIf (config.modules.proxy.default == "clash") "shanyouli/tap/gui-for-clash")
          "shanyouli/tap/clashbar" # "clash-verge-rev"
        ]
        ++ optionals (
          config.modules.app.editor.zed.enable && (config.modules.app.editor.zed.package == null)
        ) [ "zed" ]
        ++ optionals (config.modules.app.tg.enable && (config.modules.app.tg.package == null)) [
          "telegram"
        ];
        brews = [
          # "mysql"
          "mist-cli"
          "mole"
        ];
        masApps = mkMerge [
          (mkIf (config.modules.gui.enable && (config.modules.proxy.default != "")) {
            # karing = 6472431552; # 美区账号登录，一个兼容 clash-meta 的 sing-box vpn 工具
          })
          {
            # "Amphetamine" = 937984704; # 咖啡因，防止系统休眠
            "text-scaner" = 1452523807; # 文本扫描
            "pipad-calc" = 1482575592; # 高颜值的计算器
            # "vidhub" = 1659622164; # 视频管理,需要网速足够好
            # "medis" = 1579200037; # redis 管理工具, 可免费使用，
            # "devhub" = 6476452351; # 试用小工具合集
            # "mineweeper" = 1475921958; # 扫雷
          }
        ];
      };
      user.packages = [ pkgs.mas ];
    }
  ]);
}
