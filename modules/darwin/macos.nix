{
  lib,
  my,
  config,
  ...
}:
with builtins;
with lib;
with my; let
  cfg = config.modules.macos;
in {
  options = with lib; {
    modules.macos = {
      enable = mkEnableOption ''
        Whether to enable macos module
      '';
      stopAutoReopen = mkEnableOption ''
        Stopping the repon program when starting up after a system shutdown!
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
      environment.variables = {
        LANG = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
      macos.systemScript.StopAutoReopen = {
        enable = cfg.stopAutoReopen;
        text = ''
          mac_UUID=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}')
          mac_loginFile=${config.user.home}/Library/Preferences/ByHost/com.apple.loginwindow.''${mac_UUID}.plist
          if [[ -f $mac_loginFile ]]; then
            if $(grep ":TALAppsToRelaunchAtLogin" $mac_loginFile > /dev/null); then
              /usr/bin/chflags nouchg $mac_loginFile
              /usr/libexec/PlistBuddy -c 'Delete :TALAppsToRelaunchAtLogin' $mac_loginFile
              /usr/bin/chflags uimmutable $mac_loginFile
            fi
          fi
          unset mac_UUID mac_loginFile
        '';
        desc = "Stopping the repon program when starting up after a system shutdown!";
      };
      modules.shell.zsh.pluginFiles = ["macos"];
      system = {
        defaults = {
          # ".GlobalPreferences".com.apple.sound.beep.sound = "Funk";
          LaunchServices.LSQuarantine = false;
          # auto UPdate settings
          SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
          # login window settings
          loginwindow.GuestEnabled = false;
          loginwindow.SHOWFULLNAME = false;
          NSGlobalDomain = {
            AppleFontSmoothing = 2;
            AppleKeyboardUIMode = 3;
            AppleMeasurementUnits = "Centimeters";
            AppleMetricUnits = 1;
            ApplePressAndHoldEnabled = false;
            AppleShowAllExtensions = true;
            AppleShowScrollBars = "Automatic";
            AppleTemperatureUnit = "Celsius";
            InitialKeyRepeat = 30;
            KeyRepeat = 1;
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticDashSubstitutionEnabled = false;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = false;
            NSDocumentSaveNewDocumentsToCloud = false;
            NSNavPanelExpandedStateForSaveMode = true;
            NSNavPanelExpandedStateForSaveMode2 = true;
            NSTableViewDefaultSizeMode = 2;
            NSTextShowsControlCharacters = true;
            NSWindowResizeTime = 1.0e-3;
            PMPrintingExpandedStateForPrint = true;
            PMPrintingExpandedStateForPrint2 = true;
            # see@ https://github.com/jordanbaird/Ice/issues/201
            # ice 工具目前无法在总是隐藏 menubar 的状态下工作
            _HIHideMenuBar = true;
            # if config.modules.macos.ui.ice.enable
            # then false
            # else true;
            # com.apple.mouse.tapBehavior = 1;
            # com.apple.sound.beep.feedback = 0;
            # com.apple.springing.delay = 0;
            # com.apple.springing.enabled = true;
            "com.apple.sound.beep.feedback" = 0;
            "com.apple.sound.beep.volume" = 0.0;
          };

          dock = {
            autohide = true;
            autohide-delay = 0.0;
            autohide-time-modifier = 0.5;
            tilesize = 40;
            orientation = "bottom";
            show-recents = false;
            showhidden = true;
            # static-only = true;
            show-process-indicators = true;

            dashboard-in-overlay = true;
            expose-animation-duration = 0.1;
            expose-group-by-app = true;
            launchanim = false;
            mineffect = "genie";
            minimize-to-application = true;
            mouse-over-hilite-stack = true;

            # Hot corners, reset them all.
            # Not supported in nix-darwin yet
            # wvous-tl-corner = 0;
            # wvous-tl-modifier = 0;
            # wvous-tr-corner = 0;
            # wvous-tr-modifier = 0;
            # wvous-bl-corner = 0;
            # wvous-bl-modifier = 0;
            # wvous-br-corner = 0;
            # wvous-br-modifier = 0;
          };

          finder = {
            AppleShowAllExtensions = true;
            # QuitMenuItem = true;
            _FXShowPosixPathInTitle = false; # In Big Sur this is so UGLY!
          };
          # trackpad settings
          trackpad = {
            # silent clicking = 0, default = 1
            ActuationStrength = 0;
            # enable tap to click
            Clicking = true;
            # firmness level, 0 = lightest, 2 = heaviest
            FirstClickThreshold = 1;
            # firmness level for force touch
            SecondClickThreshold = 1;
            # don't allow positional right click
            TrackpadRightClick = false;
            # three finger drag for space switching
            # TrackpadThreeFingerDrag = true;
          };
          # firewall settings
          alf = {
            # 0 = disabled 1 = enabled 2 = blocks all connections except for essential services
            globalstate = 1;
            loggingenabled = 0;
            stealthenabled = 1;
          };
        };

        keyboard = {
          enableKeyMapping = true;
          # remapCapsLockToEscape = true;
        };
      };
    };
}
