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
{
  options.macos = with types; {
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
        sudo -u ${config.user.name} --set-home ${config.my.user.script}
        # 使用 nvd 取代
        # if [[ -e /run/current-system ]]; then
        #   echo "Update software version changes..."
        #   nix store diff-closures /run/current-system $systemConfig
        # fi
      '';
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
                if ( $mac_loginFile |path exists ) {
                  if (open $mac_loginFile |decode utf-8 | into string | str contains "TALAppsToRelaunchAtLogin") {
                     /usr/bin/chflags nouchg $mac_loginFile
                     /usr/libexec/PlistBuddy -c 'Delete :TALAppsToRelaunchAtLogin' $mac_loginFile
                     /usr/bin/chflags uimmutable $mac_loginFile
                  }
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
