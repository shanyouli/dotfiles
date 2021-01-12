# Theme modules are a special beast. They're the only modules that are deeply
# intertwined with others, and are solely responsible for aesthetics. Disabling
# a theme module should never leave a system non-functional.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  options.modules.theme = with types; {
    enable = mkBoolOpt false;
    active = mkOption {
      type = nullOr str;
      default = null;
      apply = v: if elem v [ "dark" "light" "mirage" "nord" ]
                 then v
                 else "mirage";
      description = ''
        Name of the theme to enable. Can be overridden by the THEME environment
        variable. Themes can also be hot-swapped with 'hey theme $THEME'.
      '';
    };

    wallpaper = mkOpt (either path null) null;

    loginWallpaper = mkOpt (either path null)
      (if cfg.wallpaper != null
       then toFilteredImage cfg.wallpaper "-gaussian-blur 0x2 -modulate 70 -level 5%"
       else null);

    gtk = {
      theme = mkOpt str "";
      iconTheme = mkOpt str "";
      cursorTheme = mkOpt str "";
    };

    onReload = mkOpt (attrsOf lines) {};
  };

  config = mkIf cfg.enable (mkMerge [
    # Desktop (X11) theming
    (mkIf config.services.xserver.enable {
      user.packages = with pkgs; [
        unstable.dracula-theme
        qogir-icon-theme
      ];
      # Login screen theme
      services.xserver.displayManager.lightdm.greeters.mini.extraConfig = ''
        text-color = "#ff79c6"
        password-background-color = "#1E2029"
        window-color = "#181a23"
        border-color = "#181a23"
      '';

      # Other dotfiles
      home.configFile = with config.modules; mkMerge [
        {
          # Sourced from sessionCommands in modules/themes/default.nix
          "xtheme/90-theme".source = ./config/Xresources;
        }
        (mkIf desktop.bspwm.enable {
          "bspwm/rc.d/polybar".source = ./config/polybar/run.sh;
          "bspwm/rc.d/theme".source = ./config/bspwmrc;
        })
        (mkIf desktop.apps.rofi.enable {
          "rofi/theme" = { source = ./config/rofi; recursive = true; };
        })
        (mkIf (desktop.bspwm.enable || desktop.stumpwm.enable) {
          "polybar" = { source = ./config/polybar; recursive = true; };
        })
      ];
    })
    {
      modules = {
        theme = {
          wallpaper = mkDefault ./config/wallpaper.png;
          gtk = {
            theme = "Dracula";
            iconTheme = "Qogir";
            cursorTheme = "Qogir";
          };
        };

        shell.tmux.rcFiles = [ ./config/tmux.conf ];
        desktop.browsers = {
          firefox.userChrome = concatMapStringsSep "\n" readFile [
            ./config/firefox/userChrome.css
          ];
          qutebrowser.userStyles = concatMapStringsSep "\n" readFile [
          # qutebrowser.userStyles = concatMapStringsSep "\n" toCSSFile [
            ./config/userstyles/qutebrowser/github.scss
            ./config/userstyles/qutebrowser/monospace-textareas.scss
            ./config/userstyles/qutebrowser/quora.scss
            ./config/userstyles/qutebrowser/stackoverflow.scss
            ./config/userstyles/qutebrowser/xkcd.scss
            ./config/userstyles/qutebrowser/youtube.scss
          ];
        };
      };
    }
    # Read xresources files in ~/.config/xtheme/* to allow modular
    # configuration of Xresources.
    (let xrdb = ''${pkgs.xorg.xrdb}/bin/xrdb -merge "$XDG_CONFIG_HOME"/xtheme/*'';
     in {
       services.xserver.displayManager.sessionCommands = xrdb;
       modules.theme.onReload.xtheme = xrdb;
     })

    {
      home.configFile = {
        # GTK
        "gtk-3.0/settings.ini".text = ''
          [Settings]
          ${optionalString (cfg.gtk.theme != "")
            ''gtk-theme-name=${cfg.gtk.theme}''}
          ${optionalString (cfg.gtk.iconTheme != "")
            ''gtk-icon-theme-name=${cfg.gtk.iconTheme}''}
          ${optionalString (cfg.gtk.cursorTheme != "")
            ''gtk-cursor-theme-name=${cfg.gtk.cursorTheme}''}
          gtk-fallback-icon-theme=gnome
          gtk-application-prefer-dark-theme=true
          gtk-xft-hinting=1
          gtk-xft-hintstyle=hintfull
          gtk-xft-rgba=none
        '';
        # GTK2 global theme (widget and icon theme)
        "gtk-2.0/gtkrc".text = ''
          ${optionalString (cfg.gtk.theme != "")
            ''gtk-theme-name="${cfg.gtk.theme}"''}
          ${optionalString (cfg.gtk.iconTheme != "")
            ''gtk-icon-theme-name="${cfg.gtk.iconTheme}"''}
          gtk-font-name="Sans 10"
        '';
        # QT4/5 global theme
        "Trolltech.conf".text = ''
          [Qt]
          ${optionalString (cfg.gtk.theme != "")
            ''style=${cfg.gtk.theme}''}
        '';
      };
    }

    (mkIf (cfg.wallpaper != null)
      (let wCfg = config.services.xserver.desktopManager.wallpaper;
           command = ''
             if [ -e "$XDG_DATA_HOME/wallpaper" ]; then
               ${pkgs.feh}/bin/feh --bg-${wCfg.mode} \
                 ${optionalString wCfg.combineScreens "--no-xinerama"} \
                 --no-fehbg \
                 $XDG_DATA_HOME/wallpaper
             fi
          '';
       in {
         # Set the wallpaper ourselves so we don't need .background-image and/or
         # .fehbg polluting $HOME
         services.xserver.displayManager.sessionCommands = command;
         modules.theme.onReload.wallpaper = command;

         home.dataFile = mkIf (cfg.wallpaper != null) {
           "wallpaper".source = cfg.wallpaper;
         };
       }))

    (mkIf (cfg.loginWallpaper != null) {
      services.xserver.displayManager.lightdm.background = cfg.loginWallpaper;
    })

    (mkIf (cfg.onReload != {})
      (let reloadTheme =
             with pkgs; (writeScriptBin "reloadTheme" ''
               #!${stdenv.shell}
               echo "Reloading current theme: ${cfg.active}"
               ${concatStringsSep "\n"
                 (mapAttrsToList (name: script: ''
                   echo "[${name}]"
                   ${script}
                 '') cfg.onReload)}
             '');
       in {
         user.packages = [ reloadTheme ];
         system.userActivationScripts.reloadTheme = ''
           [ -z "$NORELOAD" ] && ${reloadTheme}/bin/reloadTheme
         '';
       }))
  ]);
}
