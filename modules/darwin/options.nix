{
  pkgs,
  lib,
  my,
  config,
  options,
  ...
}:
with lib;
with my; let
  cfg = config.macos;
  filterEnabledTexts = dict: let
    attrList = lib.attrValues dict;
    filterLambda = x:
      if builtins.hasAttr "enable" x
      then x.enable
      else true;
    sortLambda = x: y: let
      levelx =
        if builtins.hasAttr "level" x
        then x.level
        else 50;
      levely =
        if builtins.hasAttr "level" y
        then y.level
        else 50;
    in
      levelx < levely;
    sortFn = la: pkgs.lib.sort sortLambda la;
  in
    lib.concatMapStrings (enableText: ''
      ${lib.optionalString (hasAttr "desc" enableText)
        "echo-info '${enableText.desc}' "}
      ${enableText.text}
    '') (sortFn (lib.filter filterLambda attrList));
  prevtext = ''
    #!${pkgs.stdenv.shell}

    # HACK: Unable to use nix installed git in scripts
    export PATH=/usr/bin:$PATH
    export TERM="xterm-256color"

    # 一些echo 函数
    if command -v tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
    fi
    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        BOLD="$(tput bold)"
        NORMAL="$(tput sgr0)"
    else
        RED="\e[31m"
        GREEN="\e[32m"
        YELLOW="\e[33m"
        BLUE="\e[34m"
        BOLD="\e[1m"
        NORMAL="\e[0m"
    fi
    echo-debug() { printf "''${BLUE}''${BOLD}$*''${NORMAL}\n"; }
    echo-info() { printf "''${GREEN}''${BOLD}$*''${NORMAL}\n"; }
    echo-warn() { printf "''${YELLOW}''${BOLD}$*''${NORMAL}\n"; }
    echo-error() { printf "''${RED}''${BOLD}$*''${NORMAL}\n"; }
  '';
  userScripts = pkgs.writeScript "postUserScript" ''
    ${prevtext}
    ${filterEnabledTexts cfg.userScript}
    ${config.home.initScript}
  '';
  systemScripts = pkgs.writeScript "postSystemScript" ''
    ${prevtext}
    ${filterEnabledTexts cfg.systemScript}
  '';
in {
  options.macos = with types; {
    userScript = mkOpt attrs {};
    systemScript = mkOpt attrs {};
  };
  config = mkMerge [
    {
      programs.bash.enable = config.modules.shell.bash.enable;
      user.packages = with pkgs.unstable.darwinapps;
        [
          lporg
          switchaudio-osx
          # aerospace
          pkgs.unstable.mkalias
          pkgs.terminal-notifier
        ]
        ++ optionals config.modules.app.editor.emacs.enable [
          pkgs.unstable.darwinapps.pngpaste
          (pkgs.unstable.darwinapps.emacsclient.override {
            emacsClientBin = "${config.modules.app.editor.emacs.pkg}/bin/emacsclient";
            withNotify = true;
          })
        ];
      time.timeZone = mkDefault my.timezone;
      modules = {
        shell = {
          aliases.emacs = let
            baseDir =
              if config.modules.macos.app.enable
              then config.modules.macos.app.path
              else "${config.modules.app.editor.emacs.pkg}/Applications";
          in
            optionalString config.modules.app.editor.emacs.enable "${baseDir}/Emacs.app/Contents/MacOS/Emacs";
          nushell.rcInit = ''
            # 修复macos上nushell自带的open和外部命令open的冲突
            alias nuopen = open
            alias open = ^open
          '';
        };

        gui.enable = mkDefault true;
      };

      system.activationScripts.postActivation.text = ''
        echo "System script executed after system activation"
        ${systemScripts}
        echo "User script excuted after system activation"
        sudo -u ${config.user.name} --set-home ${userScripts}
        if [[ -e /run/current-system ]]; then
          echo "Update software version changes..."
          nix store diff-closures /run/current-system $systemConfig
        fi
      '';
      macos = {
        systemScript = {
          removeNixApps.text = ''
            echo-info "Remove /Applications/Nix\ Apps ..."
            if [[ -e '/Applications/Nix Apps' ]]; then
              $DRY_RUN_CMD rm -rf '/Applications/Nix Apps'
            fi
          '';
          zshell.text = ''
            echo-info "setting Default Shell"
            chsh -s /run/current-system/sw/bin/zsh ${config.user.name}
          '';
          initXDG = {
            enable = true;
            text = ''
              if ! [[ -d ${config.modules.xdg.value.XDG_RUNTIME_DIR} ]] ; then
                mkdir -p ${config.modules.xdg.value.XDG_RUNTIME_DIR}
                chown -R "${config.user.name}" ${config.modules.xdg.value.XDG_RUNTIME_DIR}
                chmod +755 ${config.modules.xdg.value.XDG_RUNTIME_DIR}
              fi
            '';
          };
        };

        userScript = {
          clear_zsh.text = ''
            echo-info "Clear zsh ..."
            if command -v fd >/dev/null 2>&1; then
              if [[ -d  ${config.env.ZDOTDIR} ]]; then
                fd . ${config.env.ZDOTDIR} -e zwc -t f -X command rm  -vf {}
              fi
              if [[ -d ${config.env.ZSH_CACHE}/cache ]]; then
                fd . ${config.env.ZSH_CACHE} -e zwc -t f -X command rm -vf {}
              fi
            else
              if [[ -d  ${config.env.ZDOTDIR} ]]; then
                find ${config.env.ZDOTDIR} -name "*.zwc" -type f -exec command rm -vf {} \;
              fi
              if [[ -d ${config.env.ZSH_CACHE}/cache ]]; then
                find ${config.env.ZSH_CACHE} -name "*.zwc" -type f -exec command rm -vf {} \;
              fi
            fi
            if [[ -f ''${XDG_CACHE_HOME:-~/.cache}/themes/default/zshrc.zwc ]] ; then
              $DRY_RUN_CMD rm -vf ''${XDG_CACHE_HOME:-~/.cache}/themes/default/zshrc.zwc
            fi
            # 禁止在 USB 卷创建元数据文件, .DS_Store
            defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
            # 禁止在网络卷创建元数据文件
            defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
            # https://github.com/nikitabobko/AeroSpace?tab=readme-ov-file
            #  you can move windows by holding ctrl+cmd and dragging any part of the window (not necessarily the window title)
            defaults write -g NSWindowShouldDragOnGesture YES
          '';
          initRust = {
            inherit (config.modules.dev.rust) enable;
            desc = "init rust";
            text = config.modules.dev.rust.initScript;
          };
          initNvim = {
            inherit (config.modules.app.editor.nvim) enable;
            desc = "Init nvim";
            text = config.modules.app.editor.nvim.script;
          };
          initQbWebUI = {
            enable = config.modules.app.qbittorrent.webScript != "";
            text = config.modules.app.qbittorrent.webScript;
          };
          initMysql = {
            inherit (config.modules.db.mysql) enable;
            text = config.modules.db.mysql.script;
            desc = "init mysql ...";
          };
          linkChromeApp = let
            appEn = config.modules.macos.app.enable;
            mchrome = config.modules.gui.browser.chrome;
            enable = mchrome.enable && mchrome.dev.enable && appEn && (! mchrome.useBrew);
          in {
            inherit enable;
            desc = "Link Google Chrome.app";
            level = 100;
            text = ''
              if [[ -e "${config.user.home}/Applications/Myapps/Chromium.app" ]]; then
                _google_chrome_app="/Applications/Google Chrome.app"
                if [[ -e $_google_chrome_app ]]; then
                  $DRI_RUN_CMD rm -rf "$_google_chrome_app"
                fi
                $DRY_RUN_CMD ln -sf "${config.user.home}/Applications/Myapps/Chromium.app" "$_google_chrome_app"
                unset _google_chrome_app
              elif [[ -e "${config.user.home}/Applications/Myapps/Google Chrome.app" ]]; then
                $DRY_RUN_CMD ln -sf "${config.user.home}/Applications/Myapps/Google Chrome.app" "/Applications/"
              fi
            '';
          };
          initDevInit = {
            enable = config.modules.dev.lang != [];
            desc = "Init dev language manager ...";
            inherit (config.modules.dev.manager) text;
          };
        };
      };
    }
    (mkIf config.modules.gpg.enable {
      modules.service.env.GNUPGHOME = config.env.GNUPGHOME;
    })
    (mkIf config.modules.gopass.enable {
      modules.service.env.PASSWORD_STORE_DIR = config.env.PASSWORD_STORE_DIR;
    })
    (mkIf config.modules.proxy.sing-box.enable {
      environment.etc."sudoers.d/singbox".text = sudoNotPass (lib.getExe config.modules.proxy.sing-box.package);
    })
    (mkIf config.modules.proxy.sing-box.enable {
      environment.etc."sudoers.d/clash".text = sudoNotPass (lib.getExe config.modules.proxy.clash.package);
    })
  ];
}
