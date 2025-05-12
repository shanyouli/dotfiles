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
  cfg = config.macos;
  filterEnabledTexts =
    dict:
    let
      attrList = lib.attrValues dict;
      filterLambda = x: if builtins.hasAttr "enable" x then x.enable else true;
      sortLambda =
        x: y:
        let
          levelx = if builtins.hasAttr "level" x then x.level else 50;
          levely = if builtins.hasAttr "level" y then y.level else 50;
        in
        levelx < levely;
      sortFn = la: pkgs.lib.sort sortLambda la;
    in
    lib.concatMapStrings (enableText: ''
      ${lib.optionalString (hasAttr "desc" enableText) "echo-info '${enableText.desc}' "}
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
    ${config.my.user.script}
  '';
in
{
  options.macos = with types; {
    userScript = mkOpt attrs { };
    relaunchApp.enable = mkEnableOption ''
      whether to relaunch app at login
    '';
  };
  config = mkMerge [
    {
      programs.bash.enable = config.modules.shell.bash.enable;
      user.packages =
        with pkgs.unstable.darwinapps;
        [
          switchaudio-osx # broken
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
          aliases.emacs =
            let
              baseDir =
                if config.modules.macos.app.way == "copy" then
                  config.modules.macos.app.path
                else
                  "${config.modules.app.editor.emacs.pkg}/Applications";
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
        ${config.my.system.script}
        echo "User script excuted after system activation"
        sudo -u ${config.user.name} --set-home ${userScripts}
        # 使用 nvd 取代
        # if [[ -e /run/current-system ]]; then
        #   echo "Update software version changes..."
        #   nix store diff-closures /run/current-system $systemConfig
        # fi
      '';
      macos = {
        userScript = {
          initDevInit = {
            enable = config.modules.dev.lang != [ ];
            desc = "Init dev language manager ...";
            inherit (config.modules.dev.manager) text;
          };
        };
      };
      my = {
        system.init = {
          removeNixApps = ''
            if ("/Applications/Nix Apps" | path exists) {
              ^rm -rf "/Applications/Nix Apps"
            }
          '';
          defaultShell = ''
            chsh -s /run/current-system/sw/bin/${config.modules.shell.default} ${config.user.name}
          '';
        };
        user = {
          init = {
            defaultUSB = ''
              # 禁止在 USB 卷创建元数据文件, .DS_Store
              defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
              # 禁止在网络卷创建元数据文件
              defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
              # https://github.com/nikitabobko/AeroSpace?tab=readme-ov-file
              #  you can move windows by holding ctrl+cmd and dragging any part of the window (not necessarily the window title)
              defaults write -g NSWindowShouldDragOnGesture YES
            '';
            StopAutoReopen = {
              enable = !config.macos.relaunchApp.enable;
              text = ''
                let mac_loginFile = [
                  "${my.homedir}",
                  "Library",
                  "Preferences"
                  "ByHost",
                  $"com.apple.loginwindow.(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | awk -F'\"' '/IOPlatformUUID/{print $4}').plist"
                ] | path join
                if (open $mac_loginFile |decode utf-8 | into string | str contains "TALAppsToRelaunchAtLogin") {
                   /usr/bin/chflags nouchg $mac_loginFile
                   /usr/libexec/PlistBuddy -c 'Delete :TALAppsToRelaunchAtLogin' $mac_loginFile
                   /usr/bin/chflags uimmutable $mac_loginFile
                }
              '';
              desc = "Stop Auto Reopen app at login.";
            };
          };
          extra = ''
            ${optionalString config.macos.relaunchApp.enable ''
              log warning $"If you previously set the config.macos.relaunchApp.enable option, execute the following code"
              log warning $"    (ansi u)'/usr/bin/chflags nouchg ~/Library/Preferences/ByHost/com.apple.loginwindow.*.plist'(ansi n)"
            ''}
          '';
        };
      };
    }
    (mkIf config.modules.gpg.enable { modules.service.env.GNUPGHOME = config.env.GNUPGHOME; })
    (mkIf config.modules.gopass.enable {
      modules.service.env.PASSWORD_STORE_DIR = config.env.PASSWORD_STORE_DIR;
    })
    (mkIf config.modules.proxy.sing-box.enable {
      environment.etc."sudoers.d/singbox".source = sudoNotPass (
        lib.getExe config.modules.proxy.sing-box.package
      );
    })
    (mkIf config.modules.proxy.sing-box.enable {
      environment.etc."sudoers.d/clash".source = sudoNotPass (
        lib.getExe config.modules.proxy.clash.package
      );
    })
  ];
}
